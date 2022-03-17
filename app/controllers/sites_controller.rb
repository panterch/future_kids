class SitesController < ApplicationController
  authorize_resource

  def edit
  end

  def show
    # in xlsx format show is a full dump of the site
    if 'xlsx' == params[:format]
      @kids = Kid.all
      @mentors = Mentor.all
      @kid_mentor_relations = KidMentorRelation.all
      return render xlsx: 'show'
    # normal call redirects to the site wide features
    else
      redirect_to edit_site_url
    end
  end

  def update
    @site.attributes = site_params
    if(@site.terms_of_use_content_changed?)
      User.update_all(terms_of_use_accepted: false)
    end

    if @site.save
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
      :comment_bcc, :notifications_default_email, :teachers_can_access_reviews,
      :kids_schedule_hourly, :terms_of_use_content, :public_signups_active,
      :title, :css
    )
  end
end
