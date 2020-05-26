require 'spec_helper'

describe DocumentTreeview do

  let(:dtv) { DocumentTreeview.new }
  let(:file) { fixture_file_upload(File.join(Rails.root, 'doc/gespraechsdoku.pdf'), 'application/pdf') }


  it 'deliver categories tree' do
    build(:document, category0: 'a').attachment.attach(file).record.save!
    build(:document, category0: 'a', category1: 'b').attachment.attach(file).record.save!
    build(:document, category0: 'a', category1: 'b', category2: 'c1').attachment.attach(file).record.save!

    build(:document, category0: 'a', category1: 'b', category2: 'c2').attachment.attach(file).record.save!
    build(:document, category0: 'x', category1: 'y').attachment.attach(file).record.save!

    tree =  dtv.categories_tree

    expect(tree['x'].keys).to eq(['y'])
    expect(tree['a']['b'].keys).to eq(['c1', 'c2'])
  end

  it 'transforms nodes to js' do
    build(:document, title: 'a', category0: 'a').attachment.attach(file).record.save!
    build(:document, title: 'a b', category0: 'a', category1: 'b').attachment.attach(file).record.save!
    build(:document, title: 'a b c1', category0: 'a', category1: 'b', category2: 'c1').attachment.attach(file).record.save!
    build(:document, title: 'a b c2', category0: 'a', category1: 'b', category2: 'c2').attachment.attach(file).record.save!
    build(:document, title: 'x y', category0: 'x', category1: 'y').attachment.attach(file).record.save!

    js_nodes = dtv.category_js_nodes
    expect(js_nodes[0][:text]).to eq('a')
    expect(js_nodes[0][:nodes].first[:text]).to eq('b')
  end

  it 'transform appends documents to nodes js' do
    build(:document, title: 'doc a', category0: 'a').attachment.attach(file).record.save!
    build(:document, title: 'doc a b', category0: 'a', category1: 'b').attachment.attach(file).record.save!
    build(:document, title: 'doc a b c1', category0: 'a', category1: 'b', category2: 'c1').attachment.attach(file).record.save!
    build(:document, title: 'doc a b c2', category0: 'a', category1: 'b', category2: 'c2').attachment.attach(file).record.save!
    build(:document, title: 'doc x y', category0: 'x', category1: 'y').attachment.attach(file).record.save!

    js_nodes = dtv.document_js_nodes
    expect(js_nodes[0][:text]).to eq('a')
    expect(js_nodes[0][:nodes][0][:text]).to eq('b')
    expect(js_nodes[0][:nodes][1][:text]).to eq('doc a')
    expect(js_nodes[0][:nodes][0][:nodes][0][:text]).to eq('c1')
  end

  it 'sorts documents by title' do
    build(:document, title: 'b', category0: 'a').attachment.attach(file).record.save!
    build(:document, title: 'x', category0: 'a').attachment.attach(file).record.save!
    build(:document, title: 'a', category0: 'a').attachment.attach(file).record.save!
    build(:document, title: '1', category0: 'a').attachment.attach(file).record.save!

    js_nodes = dtv.document_js_nodes
    expect(js_nodes[0][:nodes][0][:text]).to eq('1')
    expect(js_nodes[0][:nodes][1][:text]).to eq('a')
    expect(js_nodes[0][:nodes][2][:text]).to eq('b')
    expect(js_nodes[0][:nodes][3][:text]).to eq('x')
  end

  it 'sorts documents after folders by title' do
    build(:document, title: 'x', category0: 'cat0').attachment.attach(file).record.save!
    build(:document, title: '2', category0: 'cat0', category1: 'cat2').attachment.attach(file).record.save!
    build(:document, title: '1', category0: 'cat0', category1: 'cat1').attachment.attach(file).record.save!
    build(:document, title: 'a', category0: 'cat0').attachment.attach(file).record.save!

    js_nodes = dtv.document_js_nodes
    expect(js_nodes[0][:nodes][0][:text]).to eq('cat1')
    expect(js_nodes[0][:nodes][1][:text]).to eq('cat2')
    expect(js_nodes[0][:nodes][2][:text]).to eq('a')
    expect(js_nodes[0][:nodes][3][:text]).to eq('x')
  end


  it 'converts arrays to hashes' do
    h = dtv.a_to_h(%w(a b c), {})
    expect(h.keys).to eq(['a'])
    expect(h['a']['b']['c']).to eq({})

    h = dtv.a_to_h(%w(a b d), h)
    expect(h['a']['b'].keys.sort).to eq(['c','d'])

  end
end
