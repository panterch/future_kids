# frozen_string_literal: true

module CrudActions
  extend ActiveSupport::Concern
  include ResourceHelpers

  included do
    before_action :alias_as_resource
  end

  def index
    respond_with @collection
  end

  def show
    respond_with @resource
  end

  def new
    respond_with @resource
  end

  def edit; end

  def create
    if @resource.save
      respond_with @resource
    else
      render :new
    end
  end

  def update
    if @resource.update(resource_params)
      respond_with @resource
    else
      render :edit
    end
  end

  def destroy
    @resource.destroy
    respond_with @resource
  end

  private

  def alias_as_resource
    @resource = instance_variable_get("@#{resource_name}")
  end
end
