require 'spec_helper'

describe DocumentTreeview do

  let(:dtv) { DocumentTreeview.new }

  it 'deliver categories tree' do
    create(:document, category0: 'a')
    create(:document, category0: 'a', category1: 'b')
    create(:document, category0: 'a', category1: 'b', category2: 'c1')
    create(:document, category0: 'a', category1: 'b', category2: 'c2')
    create(:document, category0: 'x', category1: 'y')

    tree =  dtv.categories_tree

    expect(tree['x'].keys).to eq(['y'])
    expect(tree['a']['b'].keys).to eq(['c1', 'c2'])
  end

  it 'transforms nodes to js' do
    create(:document, title: 'a', category0: 'a')
    create(:document, title: 'a b', category0: 'a', category1: 'b')
    create(:document, title: 'a b c1', category0: 'a', category1: 'b', category2: 'c1')
    create(:document, title: 'a b c2', category0: 'a', category1: 'b', category2: 'c2')
    create(:document, title: 'x y', category0: 'x', category1: 'y')

    js_nodes = dtv.category_js_nodes
    expect(js_nodes[0][:text]).to eq('a')
    expect(js_nodes[0][:nodes].first[:text]).to eq('b')
  end

  it 'transform appends documents to nodes js' do
    create(:document, title: 'a', category0: 'a')
    create(:document, title: 'a b', category0: 'a', category1: 'b')
    create(:document, title: 'a b c1', category0: 'a', category1: 'b', category2: 'c1')
    create(:document, title: 'a b c2', category0: 'a', category1: 'b', category2: 'c2')
    create(:document, title: 'x y', category0: 'x', category1: 'y')

    js_nodes = dtv.document_js_nodes
    expect(js_nodes[0][:text]).to eq('a')
    expect(js_nodes[0][:nodes][0][:text]).to eq('a')
    expect(js_nodes[0][:nodes][1][:text]).to eq('b')
    expect(js_nodes[0][:nodes][1][:nodes][0][:text]).to eq('a b')
  end

  it 'sorts documents by title' do
    create(:document, title: 'b', category0: 'a')
    create(:document, title: 'x', category0: 'a')
    create(:document, title: 'a', category0: 'a')
    create(:document, title: '1', category0: 'a')

    js_nodes = dtv.document_js_nodes
    expect(js_nodes[0][:nodes][0][:text]).to eq('1')
    expect(js_nodes[0][:nodes][1][:text]).to eq('a')
    expect(js_nodes[0][:nodes][2][:text]).to eq('b')
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
