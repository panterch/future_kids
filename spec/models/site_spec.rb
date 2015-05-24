require 'spec_helper'

describe Site do
  it 'is created by initializer site_singleton.rb' do
    expect(Site.count).to eq(1)
  end
end
