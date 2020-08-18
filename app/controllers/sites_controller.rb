class SitesController < ApplicationController
  authorize_resource

  def edit
  end

  def show
    redirect_to edit_site_url
  end

  def update
    if @site.update(site_params)
      redirect_to edit_site_url, notice: I18n.t('crud.action.update_success')
    else
      render action: :edit
    end
  end

  private

  def site_params
    params.require(:site).permit(
      :footer_address, :footer_email, :logo, :feature_coach,
      :term_collection_start, :term_collection_end,
      :comment_bcc, :notifications_default_email, :teachers_can_access_reviews
    )
  end
end
