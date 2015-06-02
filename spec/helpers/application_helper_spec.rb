require 'spec_helper'

describe ApplicationHelper do
  describe 'boolean_collection' do
    it 'includes true' do
      expect(helper.boolean_collection).to include('Ja' => true)
    end
  end

  describe 'human date' do
    it 'formats dates' do
      expect(helper.human_date(Date.parse('1980-01-30'))).to eq('30.01.1980')
    end
    it 'guards nil' do
      expect(helper.human_date(nil)).to be_nil
    end
  end

  describe 'nav link' do
    it 'renders on explicit link entry' do
      markup = nav_link('text', '/link')
      expect(markup).to eq('<li class=""><a href="/link">text</a></li>')
    end
    it 'renders on convenience link entry' do
      markup = nav_link(:principal)
      expect(markup).to eq('<li class=""><a href="/principals">SL/QUIMS</a></li>')
    end
    it 'honors translations from AR' do
      I18n::Backend::ActiveRecord.new.store_translations(:de, nav: { principal: 'P AR' })
      markup = nav_link(:principal)
      expect(markup).to eq('<li class=""><a href="/principals">P AR</a></li>')
    end
    it 'fallbacks on model name translation if no nav translation set' do
      markup = nav_link(:teacher)
      expect(markup).to eq('<li class=""><a href="/teachers">Lehrperson</a></li>')
    end
  end

  describe 'term collection' do
    it 'renders terms' do
      @site = Site.new(term_collection_start: 2011, term_collection_end: 2015)
      expect(term_collection.first).to eq('2011 Frühling')
      expect(term_collection.last).to eq('2015 Herbst')
    end
  end
end
