require 'spec_helper'

describe Document do

  include ActionDispatch::TestProcess::FixtureFile
  let(:file) { fixture_file_upload('gespraechsdoku.pdf', 'application/pdf') }

  it 'attaches files' do
    d = Document.new(title: 'test document')
    d.attachment.attach(file)
    d.save!
    expect(d.reload.attachment.present?).to eq true
  end
end
