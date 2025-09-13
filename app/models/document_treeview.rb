# helps building the json format that is used by the treeview plugin
class DocumentTreeview
  def initialize(user_class)
    @user_class = user_class
  end

  # access the database to identify all the (flat) stored categories and bring
  # them into a tree structure
  def categories_tree
    tree = {}
    category_keys = retrieve_documents.order(:category0).pluck(:category0, :category1, :category2, :category3,
                                                               :category4, :category5, :category6, :category7)
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
      node[:nodes] = category_js_nodes(cat_tree[key]) unless cat_tree[key].empty?
      nodes << node
    end
    nodes
  end

  # add all documents / links to the document efficient to the js formatted category
  def document_js_nodes
    js_nodes = category_js_nodes
    documents = retrieve_documents
    documents.each do |d|
      categories = [d.category0, d.category1, d.category2, d.category3, d.category4, d.category5, d.category6,
                    d.category7].compact
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
        href: Rails.application.routes.url_helpers.rails_blob_path(d.attachment.blob, only_path: true),
        documentId: d.id,
        icon: 'glyphicon glyphicon-book'
      }
      nodes.sort_by! do |node|
        key = node[:nodes] ? '0folder' : '1doc' # prefer folders over documents
        key += node[:text]
        key
      end
    end
    js_nodes
  end

  def retrieve_documents
    @user_class == Admin ? Document.all : Document.where(admin_only: false)
  end

  # helper method to transform category arrays to an array
  def a_to_h(arr, hash)
    return {} if arr.empty? || arr.first.blank?

    cur_key = arr.shift
    cur_hash = hash[cur_key]
    hash[cur_key] = cur_hash = {} if cur_hash.nil?
    a_to_h(arr, cur_hash)
    hash
  end
end
