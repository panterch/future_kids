class DocumentsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def create
    create!{ documents_url }
  end

end
