require 'spec_helper'

describe I18n do

  it 'looks up string from yaml file' do
    expect(I18n.t('activerecord.models.kid')).to eq('Schüler/in')
  end

  it 'overwrites tranlsation via active record' do
    I18n::Backend::ActiveRecord.new.store_translations(:de, activerecord: { models: { kid: 'Kid AR'}})
    expect(I18n::Backend::ActiveRecord::Translation.count).to eq(1)
    expect(I18n.t('activerecord.models.kid')).to eq('Kid AR')
  end

  it 'overwrites active record human_name value' do
    I18n::Backend::ActiveRecord.new.store_translations(:de, activerecord: { models: { kid: 'Kid AR'}})
    expect(Kid.model_name.human).to eq('Kid AR')
  end

  it 'is possible to create translation via normal AR model' do

  end
end

