class DocumentsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    @category_tree = Document.category_tree
    @documents_by_category = {}
    @documents.each do |d|
      key = [d.category, d.subcategory].to_json
      @documents_by_category[key] ||= []
      @documents_by_category[key] << d
    end
    @documents_json = Jbuilder.new do |json|
      json.categoryTree @category_tree
      json.documentsByCategory do
        @documents_by_category.each do |key, doc|
          json.set! key do
            json.array! doc do |d|
              json.key d.id
              json.title d.title
              json.link d.attachment.url
              if can?(:destroy, d)
                json.destroy_link document_path(d)
              end
            end
          end
        end
      end
    end.attributes!

    respond_with @documents
  end

  def create
    @document = Document.create(document_params)
    if @document.valid?
      redirect_to action: :index
    else
      render :new
    end
  end

  private

  def document_params
    params.require(:document).permit(
      :category, :subcategory, :title, :attachment
    )
  end
end
