require 'spec_helper'

describe Document do
  it "attaches files" do
    d = Document.new
    d.attachment = File.new(File.join(Rails.root, 'doc/gespraechsdoku.pdf'))
    d.save!
    File.exists?(d.reload.attachment.path)
  end

  it 'builds a ordered tree' do
    create(:document, :title => 'a1', :category => 'a')
    create(:document, :title => 'a3', :category => 'a')
    create(:document, :title => 'a2', :category => 'a')
    create(:document, :title => 'ax2', :category => 'a', :subcategory => 'x')
    create(:document, :title => 'ax1', :category => 'a', :subcategory => 'x')
    create(:document, :title => 'ay1', :category => 'a', :subcategory => 'y')
    create(:document, :title => 'ax3', :category => 'a', :subcategory => 'x')
    create(:document, :title => 'by2', :category => 'b', :subcategory => 'y')
    create(:document, :title => 'by1', :category => 'b', :subcategory => 'y')
    create(:document, :title => 'by3', :category => 'b', :subcategory => 'y')

    tree = Document.category_tree
    assert_equal %w(a b), tree.keys

    assert_equal %w(x y), tree['a']
    assert_equal %w(y), tree['b']
  end
end
