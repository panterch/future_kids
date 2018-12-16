require 'spec_helper'

describe Document do
  it 'attaches files' do
    d = Document.new(title: 'test document')
    d.attachment = File.new(File.join(Rails.root, 'doc/gespraechsdoku.pdf'))
    d.save!
    File.exist?(d.reload.attachment.path)
  end
end
