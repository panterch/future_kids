require 'spec_helper'

describe Document do
  it 'attaches files' do
    d = Document.new
    d.attachment = File.new(File.join(Rails.root, 'doc/gespraechsdoku.pdf'))
    d.save!
    File.exist?(d.reload.attachment.path)
  end

  it 'builds a ordered tree' do
    create(:document, title: 'a1', category: 'a')
    create(:document, title: 'a3', category: 'a')
    create(:document, title: 'a2', category: 'a')
    create(:document, title: 'ax2', category: 'a', subcategory: 'x')
    create(:document, title: 'ax1', category: 'a', subcategory: 'x')
    create(:document, title: 'ay1', category: 'a', subcategory: 'y')
    create(:document, title: 'ax3', category: 'a', subcategory: 'x')
    create(:document, title: 'by2', category: 'b', subcategory: 'y')
    create(:document, title: 'by1', category: 'b', subcategory: 'y')
    create(:document, title: 'by3', category: 'b', subcategory: 'y')

    tree = Document.category_tree
    expect(tree.keys).to eq %w(a b)

    expect(tree['a']).to eq %w(x y)
    expect(tree['b']).to eq %w(y)
  end

  it 'delivers in category' do
    doc = create(:document, title: 'category', category: 'a')
    create(:document, title: 'subcateg', category: 'a', subcategory: 'x')
    expect(Document.in_category('a')).to eq([doc])
  end

  it 'delivers in subcategory' do
    create(:document, title: 'c', category: 'a')
    sub = create(:document, title: 's', category: 'a', subcategory: 'x')
    expect(Document.in_subcategory('a', 'x')).to eq([sub])
  end

  it 'lists categories' do
    create(:document, title: 'a1', category: 'a', subcategory: 'x')
    create(:document, title: 'a3', category: 'a', subcategory: 'y')
    create(:document, title: 'a2', category: 'b', subcategory: 'y')
    expect(Document.categories).to eq(%w[a b])
    expect(Document.subcategories).to eq(%w[x y])
  end
end
