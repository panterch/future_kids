# helps building the json format that is used by the treeview plugin
class DocumentTreeview

  # access the database to identify all the (flat) stored categories and bring
  # them into a tree structure
  def categories_tree
    tree = {}
    category_keys = Document.order(:category0).pluck(:category0, :category1, :category2, :category3)
    category_keys.each do |keys|
      next if keys.first.blank?
      tree = a_to_h(keys, tree)
    end
    tree
  end

  # transform the format of categories tree to a format used by the
  # js to display trees in the view
  def category_js_nodes(cat_tree = categories_tree)
    nodes = []
    cat_tree.keys.sort.each do |key|
      node = { text: key, selectable: false, nodes: [] }
      unless cat_tree[key].empty?
        node[:nodes] = category_js_nodes(cat_tree[key])
      end
      nodes << node
    end
    nodes
  end

  # add all documents / links to the document efficient to the js formatted category
  def document_js_nodes
    js_nodes = category_js_nodes
    Document.all.each do |d|
      categories = [ d.category0, d.category1, d.category2, d.category3 ].compact
      nodes = js_nodes
      categories.each do |category|
        nodes.each do |node|
          if category == node[:text]
            nodes = node[:nodes]
            break
          end
        end
      end
      nodes << {
          text: d.title,
          href: d.attachment.url,
          documentId: d.id,
          icon: 'glyphicon glyphicon-book'
      }
      nodes.sort_by!{ |node| node[:text] }
    end
    js_nodes
  end

  # helper method to transform category arrays to an array
  def a_to_h(arr, hash)
    return {} if arr.empty? || arr.first.blank?
    cur_key = arr.shift
    cur_hash = hash[cur_key]
    hash[cur_key] = cur_hash = {} if cur_hash.nil?
    a_to_h(arr, cur_hash)
    return hash
  end


end
