# frozen_string_literal: true

# Builds the list of real people who could plausibly be mentioned by name in
# a kid's free text (journal notes, assessment narratives, comments), for
# NameRedactor to match against. Built fresh from the DB on every call - see
# NameRedactor for why nothing here is persisted.
class PersonDictionary
  # dictionary tokens shorter than this are excluded: short tokens (2-letter
  # German prepositions like "de"/"in") fuzzy-match all kinds of unrelated
  # words via Jaro-Winkler and cause widespread false-positive redaction
  MIN_NAME_TOKEN_LENGTH = 3

  # kids.parent is free text, not a clean "Firstname Lastname" field: real
  # production data (checked via Kid.pluck(:parent)) contains multiple
  # guardians separated by various delimiters ("Anna und Peter Muster",
  # "Lisa Beispiel & Karim Beispiel", "Tom Muster (Mutter) / Jan Muster
  # (Vater)"), inconsistent name order, and embedded free-text remarks
  # ("wohnt in Musterhausen", "Kommunikation ... über die Mutter, lea"). There
  # is no reliable way to pair first/last names or tell how many distinct
  # people are named, so every word is treated as a candidate token for one
  # composite "guardian" dictionary entry, after stripping connectors and
  # common role/annotation words that would otherwise cause false-positive
  # matches (e.g. "Mutter", "und") - erring towards over-redaction rather
  # than missing a real name is the safe direction for this feature.
  GUARDIAN_DELIMITER = %r{[,&+/()]}
  GUARDIAN_STOPWORDS = %w[
    und oder sowie bzw mutter vater eltern familie kommunikation wohnt
    wohnhaft jetzt eher ueber über die der das von in an bei fuer für mit
    com tel telefon email mail adresse kontakt
  ].freeze

  # name particles common in European surnames ("von Muster", "van Beispiel",
  # "de la Muster") are also ordinary words in running German text ("von" =
  # "of/from") - excluded as standalone dictionary tokens so they can't
  # exact-match the everyday word everywhere. The rest of a multi-word name
  # (e.g. "Muster") stays a fine match anchor on its own.
  NAME_PARTICLES = %w[von van der zu de und la].freeze

  RELATION_LOG_ROLES = {
    'mentor' => :mentor, 'secondary_mentor' => :mentor,
    'teacher' => :teacher, 'secondary_teacher' => :teacher, 'third_teacher' => :teacher,
    'admin' => :admin
  }.freeze

  ROLE_FOR_CLASS = {
    'Kid' => :kid, 'Mentor' => :mentor, 'Teacher' => :teacher, 'Admin' => :admin, 'Principal' => :principal
  }.freeze

  Person = Struct.new(:key, :role, :display_name, :name_tokens, :initial_tokens, keyword_init: true)

  # real (User/Kid) record -> dictionary key, e.g. "User_42" - shared between
  # #people (building the full list) and NameRedactor#placeholder_for_record
  # (looking up one specific record for deterministic, non-fuzzy redaction
  # of names the template inserts directly, e.g. `teacher.display_name`)
  def self.key_for(record)
    "#{record.class.base_class}_#{record.id}"
  end

  # stateless: does not depend on which kid is being redacted, so it also
  # serves as a fallback when NameRedactor is asked to redact a record that
  # isn't already in the kid's dictionary (defensive - should not normally
  # happen, since every association the template renders is also walked in
  # #build_people, but better to still redact correctly than to leak)
  def self.person_for(record, role = nil)
    return nil if record.nil?

    role ||= ROLE_FOR_CLASS.fetch(record.class.base_class.name, :other)
    Person.new(
      key: key_for(record),
      role: role,
      display_name: readable_name(record),
      name_tokens: name_words(record.name) + name_words(record.prename),
      initial_tokens: [initial(record.prename)].compact
    )
  end

  # the AI summary reads as flowing German prose, so rehydrating with the
  # admin-listing "Nachname, Vorname" format (User/Kid#display_name) would
  # read unnaturally - use the first name people are actually referred to by
  def self.readable_name(record)
    record.prename.presence || record.name
  end

  # real names can be multi-word (compound surnames, multiple given names) -
  # splitting into individual word tokens is what lets a single-word mention
  # in free text ("Sofia") match a multi-word field ("Sofia Elena
  # Muster"); comparing the word against the whole field as one token
  # would almost never score high enough
  def self.name_words(value)
    return [] if value.blank?

    # split on hyphens too (not just whitespace) so "Meier-Müller" yields
    # "Meier" and "Müller" as independently matchable tokens - see
    # NameRedactor::CORE_PATTERN for why free text is tokenized the same way
    value.split(/[\s-]+/).reject { |w| w.length < MIN_NAME_TOKEN_LENGTH || NAME_PARTICLES.include?(w.downcase) }
  end

  def self.initial(name)
    return nil if name.blank?

    "#{name.strip.first}."
  end

  def initialize(kid)
    @kid = kid
  end

  def people
    @people ||= build_people.compact.uniq(&:key)
  end

  private

  def build_people
    [
      self.class.person_for(@kid, :kid),
      guardian_person,
      self.class.person_for(@kid.teacher, :teacher),
      self.class.person_for(@kid.secondary_teacher, :teacher),
      self.class.person_for(@kid.third_teacher, :teacher),
      self.class.person_for(@kid.mentor, :mentor),
      self.class.person_for(@kid.secondary_mentor, :mentor),
      *@kid.journals.includes(:mentor).map { |journal| self.class.person_for(journal.mentor, :mentor) },
      *@kid.first_year_assessments.includes(:teacher, :mentor).flat_map do |a|
        [self.class.person_for(a.teacher, :teacher), self.class.person_for(a.mentor, :mentor)]
      end,
      *@kid.termination_assessments.includes(:teacher).map { |a| self.class.person_for(a.teacher, :teacher) },
      *@kid.relation_logs.includes(:user).map do |log|
        self.class.person_for(log.user, RELATION_LOG_ROLES.fetch(log.role, :admin))
      end,
      *Admin.all.map { |admin| self.class.person_for(admin, :admin) },
      *@kid.school&.principals&.map { |principal| self.class.person_for(principal, :principal) }
    ]
  end

  def guardian_person
    return nil if @kid.parent.blank?

    words = guardian_words
    initials, names = words.partition { |w| w.match?(/\A\p{Lu}\.\z/) }
    names = names.select { |w| w.length >= MIN_NAME_TOKEN_LENGTH }
    return nil if names.empty? && initials.empty?

    # rehydration restores the original field verbatim rather than
    # reconstructing "the" guardian name, since the field may name more than
    # one person and there is no reliable way to tell which one matched
    Person.new(key: 'kid_parent', role: :parent, display_name: @kid.parent, name_tokens: names,
               initial_tokens: initials)
  end

  def guardian_words
    @kid.parent.split(GUARDIAN_DELIMITER).flat_map { |part| part.split(/[\s-]+/) }.reject do |word|
      word.blank? || GUARDIAN_STOPWORDS.include?(word.downcase) || NAME_PARTICLES.include?(word.downcase)
    end
  end
end
