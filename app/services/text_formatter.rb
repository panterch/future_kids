# frozen_string_literal: true

# Renders the free text of the app's textareas (journals, reviews,
# assessments, notes, comments) as HTML. Works like simple_format
# (paragraphs, line breaks, sanitized), plus:
#
# - runs of lines starting with a list marker become real lists: "- Lesen",
#   "-Lesen", "• Lesen" (pasted from Word), "* Lesen" become a <ul>,
#   "1. Lesen" / "1) Lesen" an <ol> (keeping its starting number)
# - typed arrows ("->", "<-", "<->", "=>") become arrow characters
#
# Deliberately not Markdown: mentors use *, _, #, --- and indentation in
# their own ways (gender stars, math blanks like "430 + _ = 880", separator
# lines), which a Markdown parser would turn into emphasis, headings or code
# blocks. Only the stored text's display changes, the text itself is kept as
# typed (the Excel exports, plain text mails and AI profile use it as is).
class TextFormatter
  include ActionView::Helpers::TextHelper

  # longer arrows first, so "<->" doesn't end up as "<→"
  ARROWS = { '<->' => '↔', '<--' => '←', '-->' => '→', '<-' => '←', '->' => '→', '=>' => '⇒' }.freeze
  ARROW_PATTERN = Regexp.union(ARROWS.keys)

  # checked in this order, the first matching pattern decides a line's type
  LINE_TYPES = {
    blank: /\A\s*\z/,
    # a line made of one marker character repeated ("---", "* * *", "___")
    text: /\A[ \t]*([-–*_=•])(?:[ \t]*\1)+[ \t]*\z/,
    # a bare marker without text: mostly a field's whole content meaning
    # "nothing to report", sometimes an empty item next to a list
    empty_marker: /\A[ \t]*[-–•·▪*][ \t]*\z/,
    # the space after the marker is optional ("-Lesen" is very common),
    # except for "*", which without a space is mostly emphasis ("*Lob*")
    bullet: /\A[ \t]*(?:[-–•·▪](?![-–])|\*(?=[ \t]))[ \t]*(?<text>\S.*)\z/,
    # the space after the number is required, so "1.5h im Zimmer" and dates
    # like "12.3.2024" stay text
    numbered: /\A[ \t]*(?<number>\d{1,3})[.)][ \t]+(?<text>\S.*)\z/,
    # continues the list item before it
    indented: /\A[ \t]+\S/
  }.freeze
  LIST_TYPES = %i[bullet numbered].freeze

  Line = Struct.new(:raw, :type, :match) do
    def self.parse(raw)
      type, pattern = LINE_TYPES.find { |_type, pattern| pattern.match?(raw) } || [:text]
      new(raw, type, pattern&.match(raw))
    end

    def blank? = type == :blank
    def content = type == :indented ? raw.strip : match[:text]
    def number = match[:number].to_i
  end

  def self.to_html(text)
    new(text).to_html
  end

  def initialize(text)
    text = text.to_s.gsub(/\r\n?/, "\n").gsub(ARROW_PATTERN, ARROWS)
    @lines = text.split("\n").map { |raw| Line.parse(raw) }
  end

  # the text as a sequence of lists and the lines between them, the latter
  # rendered by simple_format
  def to_html
    parts = []
    index = 0
    while index < @lines.size
      list, index_after = read_list(index)
      parts.concat(list ? [list] : @lines[index...index_after])
      index = index_after
    end
    render(parts)
  end

  private

  # parts are list html and the lines between the lists
  def render(parts)
    html = parts.slice_when { |a, b| a.is_a?(Line) != b.is_a?(Line) }
                .map { |run| run.first.is_a?(Line) ? paragraphs(run) : run }
    safe_join(html.flatten.compact, "\n")
  end

  # returns the html of the list starting at index (nil if none does) and
  # the index after it
  def read_list(index)
    type = list_type_at(index)
    return [nil, index + 1] unless type

    items, index_after = read_items(type, index)
    # a single numbered line is mostly a heading-like "3. Klasse" or a date
    return [nil, index_after] if type == :numbered && items.size < 2

    [list_html(type, items), index_after]
  end

  # a bare marker right before a list is an empty first item
  def list_type_at(index)
    type = @lines[index].type
    type = @lines[index + 1]&.type if type == :empty_marker
    type if LIST_TYPES.include?(type)
  end

  # each item is its marker line plus the indented lines continuing it
  def read_items(type, index)
    items = []
    while (line = @lines[index])
      index_after = read_item_line(line, type, items, index)
      break unless index_after

      index = index_after
    end
    [items, index]
  end

  # adds the line at index to items, returns the index to continue at, or nil
  # when the list ends before it. bare markers are dropped as empty items
  def read_item_line(line, type, items, index)
    case line.type
    when type then items << [line]
    when :indented then items.last << line
    when :blank then return blank_lines_within_list(index, type)&.succ
    when :empty_marker then nil
    else return
    end
    index + 1
  end

  # the index of the last of the blank lines starting at index if another
  # item follows them, nil if they end the list
  def blank_lines_within_list(index, type)
    index += 1 while @lines[index + 1]&.blank?
    index if @lines[index + 1]&.type == type
  end

  # .text-list keeps them tight to the surrounding text (application.scss)
  def list_html(type, items)
    return tag.ul(safe_join(items.map { |lines| list_item(lines) }), class: 'text-list') if type == :bullet

    start = items.first.first.number
    tag.ol(safe_join(numbered_items(items)), class: 'text-list', start: (start unless start == 1))
  end

  # an item not numbered its predecessor + 1 ("1." followed by "3.") keeps
  # its own number
  def numbered_items(items)
    previous = nil
    items.map do |lines|
      number = lines.first.number
      value = number unless previous.nil? || number == previous + 1
      previous = number
      list_item(lines, value)
    end
  end

  def list_item(lines, value = nil)
    tag.li(safe_join(lines.map { |line| sanitize(line.content) }, tag.br), value:)
  end

  # the blank lines around a list belong to neither side
  def paragraphs(lines)
    lines = lines.drop_while(&:blank?).reverse.drop_while(&:blank?).reverse
    simple_format(lines.map(&:raw).join("\n")) if lines.any?
  end
end
