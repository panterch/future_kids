class Review
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps

  embedded_in :kid

  field :held_at, :type => Date
  field :reason
  field :kind
  field :content
  field :outcome
  field :note

  def display_name
    return "Neue Gesprächsdoku" if new_record?
    "Gesprächsdoku vom #{I18n.l(held_at)}"
  end

end
