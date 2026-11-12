# frozen_string_literal: true

class DocumentsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    @documents_json = DocumentTreeview.new(current_user.class).document_js_nodes
    respond_with @documents
  end

  def show
    # atomic counter update - validations are not relevant for download counting
    @document.increment!(:download_count) # rubocop:disable Rails/SkipsModelValidations
    redirect_to rails_blob_path(@document.attachment.blob, only_path: true), allow_other_host: false
  end

  def create
    @document = Document.create(document_params)
    if @document.valid?
      respond_with @document, location: documents_path
    else
      render :new
    end
  end

  def update
    @document.update(document_params)
    if @document.valid?
      respond_with @document, location: documents_path
    else
      render :edit
    end
  end

  # the tree deletes by ajax and reloads the page, which then shows the
  # notice. set by hand: there is no respond_with for the ajax answer
  def destroy
    @document.destroy
    flash[:notice] = t('flash.actions.destroy.notice')
    if request.xhr?
      head :no_content
    else
      redirect_to action: :index
    end
  end

  private

  def document_params
    params.expect(
      document: %i[category0 category1 category2 category3 category4 category5 category6 category7
                   title attachment admin_only]
    )
  end
end
