# frozen_string_literal: true

# Redacts real names of people associated with a kid (kid, guardian,
# teachers, mentors, admins, the kid's school's principals) from free text
# before it is sent to a third-party AI provider, matching misspellings and
# initials ("M." for "Mira") via Jaro-Winkler similarity. Each matched person
# gets a unique, stable placeholder so #rehydrate can later reverse the
# substitution unambiguously (e.g. two different mentors both mentioned in
# the same text don't collapse into one placeholder). See JournalSummarizer,
# which redacts the outgoing prompt and rehydrates the AI's response with
# the same instance/mapping.
class NameRedactor
  SIMILARITY_THRESHOLD = 0.92
  MIN_TOKEN_LENGTH = 3

  # Admin/principal are kid-independent, system-wide lists (every admin is
  # checked against every kid's text, regardless of whether they're actually
  # involved with that kid) - the larger a dictionary, the more likely some
  # entry in it randomly resembles a common German word within fuzzy-match
  # distance (confirmed during testing against real, redacted production
  # data: a real admin's surname scored 0.93 against an unrelated, very
  # common German adjective, well above SIMILARITY_THRESHOLD, and would
  # have redacted that ordinary word out of every kid's summary system-
  # wide). Kid/guardian/teacher/mentor are small,
  # contextually-certain lists (a handful of people actually tied to this
  # kid) where fuzzy typo tolerance is worth the risk; admin/principal only
  # get exact (case-insensitive) matches.
  EXACT_MATCH_ROLES = %i[admin principal].freeze

  # scans the whole text for word-shaped spans directly (letters plus
  # interior apostrophes for names like "O'Brien", with an optional single
  # trailing period) instead of pre-splitting on whitespace: real journal
  # text glues names to neighbouring words with all kinds of punctuation and
  # no space (confirmed against real production data - patterns like
  # "Peter-Mira" [hyphen], "Schwierigkeiten:Mira" [colon], "dich/Mira"
  # [slash], "vorgelesen habe.Mira" [missing space after a full stop]), and
  # enumerating every separator character as a split point is a losing
  # game. Scanning for words directly sidesteps that: only \p{L} runs (plus
  # the apostrophe glue) are ever candidates, so any other character -
  # hyphen, colon, slash, comma, parens, Unicode line separators pasted
  # from rich text - naturally acts as a boundary and is left untouched.
  # Hyphens are deliberately NOT part of the word itself even for genuine
  # compound surnames ("Meier-Müller"): there's no lexical way to tell that
  # apart from two unrelated words glued together with a hyphen, so it's
  # split too - each half still matches independently (see
  # PersonDictionary.name_words, split the same way for symmetry).
  WORD_PATTERN = /\p{L}+(?:['’]\p{L}+)*\.?/

  ROLE_LABELS = {
    kid: 'Kind',
    parent: 'ErziehungsberechtigteR',
    teacher: 'Lehrperson',
    mentor: 'Mentor',
    admin: 'Coach',
    principal: 'Schulleitung',
    other: 'Person'
  }.freeze

  def initialize(kid)
    @people = PersonDictionary.new(kid).people
    @placeholders = {} # person key => placeholder
    @mapping = {} # placeholder => real display name
    @role_counters = Hash.new(0)
  end

  # deterministic redaction for a known record (e.g. `teacher.display_name`
  # in kids/show.md.erb) - no fuzzy matching involved, since the template
  # already knows exactly whose name it is inserting. Reserve #redact for
  # genuine free text (notes, journal narratives) where a name could appear
  # anywhere, misspelled, or as an initial - fuzzy-matching *known* fields
  # instead of substituting them directly is what caused static template
  # text ("Kind", "Coach" - the labels, not values) to collide with real
  # people who happen to share a name with that vocabulary.
  def placeholder_for_record(record)
    return nil if record.nil?

    key = PersonDictionary.key_for(record)
    person = @people.find { |p| p.key == key } || PersonDictionary.person_for(record)
    placeholder_for(person)
  end

  def redact(text)
    return text if text.blank?

    result = text.gsub(WORD_PATTERN) { redact_match(Regexp.last_match) }
    # some fields are a free-text snapshot of a "Surname, Prename" string
    # (e.g. Comment#by) rather than a link to the record, so surname and
    # prename are matched as two separate word tokens even though they
    # name the same person - collapse immediately-adjacent repeats of the
    # same placeholder rather than showing it twice in a row
    result.gsub(%r{(\[\w+\d+\])(?:[\s,\-:/]+\1)+}, '\1')
  end

  def rehydrate(text)
    return text if text.blank?

    @mapping.each { |placeholder, name| text = text.gsub(placeholder) { name } }
    text
  end

  private

  def redact_match(match_data)
    match = match_data.to_s
    has_dot = match.end_with?('.')
    core = has_dot ? match[0..-2] : match
    is_initial = core.length == 1 && has_dot
    return match if is_initial && abbreviation_cluster?(match_data)

    person = best_match(is_initial ? "#{core}." : core)
    return match unless person

    "#{placeholder_for(person)}#{initial_suffix(has_dot, is_initial)}"
  end

  # a single letter followed by a period is an initial ("M.") - the only
  # case where the trailing period is actually part of the match itself,
  # rather than end-of-sentence punctuation that happened to get swept up
  def initial_suffix(has_dot, is_initial)
    has_dot && !is_initial ? '.' : ''
  end

  # German has several multi-part abbreviations built from single-letter
  # initials ("z. B." = zum Beispiel, "u. a." = unter anderem, "i. d. R." =
  # in der Regel) that are lexically indistinguishable from a real person's
  # initial in isolation. The disambiguating signal is that they cluster: a
  # genuine name-initial normally stands alone, while these idioms always
  # have another lone letter-dot token immediately before or after. Erring
  # towards leaving a name un-redacted in this narrow case beats mangling
  # common German abbreviations throughout every summary.
  def abbreviation_cluster?(match_data)
    match_data.pre_match.match?(/\p{L}\.\s*\z/) || match_data.post_match.match?(/\A\s*\p{L}\./)
  end

  def best_match(word)
    return match_by_initial(word) if word.match?(/\A\p{Lu}\.\z/)
    return nil if word.length < MIN_TOKEN_LENGTH

    match_by_similarity(word)
  end

  def match_by_initial(word)
    @people.find { |person| person.initial_tokens.any? { |t| t.casecmp?(word) } }
  end

  def match_by_similarity(word)
    scored = @people.filter_map { |person| score_person(person, word) }
    scored.select { |_person, score| score >= SIMILARITY_THRESHOLD }.max_by { |_person, score| score }&.first
  end

  def score_person(person, word)
    if EXACT_MATCH_ROLES.include?(person.role)
      return [person, 1.0] if person.name_tokens.any? { |t| t.casecmp?(word) }

      return nil
    end

    best_score = person.name_tokens.map { |t| JaroWinkler.similarity(word.downcase, t.downcase) }.max
    [person, best_score] if best_score
  end

  def placeholder_for(person)
    @placeholders[person.key] ||= begin
      @role_counters[person.role] += 1
      placeholder = "[#{ROLE_LABELS.fetch(person.role)}#{@role_counters[person.role]}]"
      @mapping[placeholder] = person.display_name
      placeholder
    end
  end
end
