class DocumentsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    @documents_json = DocumentTreeview.new(current_user.class).document_js_nodes
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

  def update
    @document.update(document_params)
    if @document.valid?
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def document_params
    params.require(:document).permit(
      :category0, :category1, :category2, :category3, :category4, :category5, :category6, :category7, :title, :attachment, :admin_only
    )
  end
end
