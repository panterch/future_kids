class DocumentsController < ApplicationController

  load_and_authorize_resource
  include CrudActions

  def index
    @category_tree = Document.category_tree
    @documents_by_category = {}
    @documents.each do |d|
      d.category = "Verschiedenes" if d.category.blank?
      @documents_by_category[d.category] ||= []
      @documents_by_category[d.category] << d
    end
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
