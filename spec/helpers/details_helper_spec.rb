# frozen_string_literal: true

require 'spec_helper'

describe DetailsHelper do
  let(:school) { create(:school, name: 'Schulhaus Nord') }
  let(:kid) { create(:kid, name: 'Muster', school: school, dob: Date.new(2015, 3, 4), translator: true) }

  def render_details(&)
    Capybara.string(helper.details_for(kid, &))
  end

  it 'renders a grid of label/value rows' do
    html = render_details { |d| d.attribute(:name) }
    row = html.find('.show-for-grid > .show-for-row.kid_name')
    expect(row).to have_css('label.show-for-label', text: Kid.human_attribute_name(:name))
    expect(row).to have_css('.show-for-value', text: 'Muster')
  end

  it 'localizes dates and booleans' do
    html = render_details { |d| d.attribute(:dob) + d.attribute(:translator) }
    expect(html).to have_css('.kid_dob .show-for-value', text: I18n.l(Date.new(2015, 3, 4)))
    expect(html).to have_css('.kid_translator .show-for-value', text: 'Ja')
  end

  it 'prefers the human_ variant of an attribute' do
    kid.update!(sex: 'm')
    html = render_details { |d| d.attribute(:sex) }
    expect(html).to have_css('.kid_sex .show-for-value', text: kid.human_sex)
  end

  it 'marks blank values' do
    html = render_details { |d| d.attribute(:secondary_mentor) }
    expect(html).to have_css('.kid_secondary_mentor.text-body-secondary .show-for-value.text-body-secondary', text: 'Keine Angabe')
  end

  it 'uses a block without arguments as the value' do
    html = render_details { |d| d.attribute(:school) { 'custom' } }
    expect(html).to have_css('.kid_school .show-for-value', text: 'custom')
  end

  it 'takes a custom label' do
    html = render_details { |d| d.attribute(:name, label: 'Nachname') }
    expect(html).to have_css('.kid_name .show-for-label', text: 'Nachname')
  end

  it 'renders collections as a list, one block call per element' do
    teacher = create(:teacher, name: 'Lehrer')
    kid.update!(teacher: teacher)
    html = Capybara.string(helper.details_for(teacher) { |d| d.association(:kids) { |k| helper.tag.li(k.name) } })
    expect(html).to have_css('.teacher_kids ul.list-unstyled li', text: 'Muster')
  end

  it 'treats an empty collection as blank' do
    teacher = create(:teacher)
    html = Capybara.string(helper.details_for(teacher) { |d| d.association(:kids) { |k| helper.tag.li(k.name) } })
    expect(html).to have_css('.teacher_kids .show-for-value', text: 'Keine Angabe')
  end
end
