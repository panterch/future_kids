class DocumentsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def index
    @category_tree = Document.category_tree
    @documents_by_category = {}
    collection.each do |d|
      d.category = "Verschiedenes" if d.category.blank?
      @documents_by_category[d.category] ||= []
      @documents_by_category[d.category] << d
    end
    index!
  end

  def create
    create!{ documents_url }
  end

end
