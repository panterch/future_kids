# frozen_string_literal: true

class SitesController < ApplicationController
  authorize_resource

  def show
    # in xlsx format show is a full dump of the site
    if params[:format] == 'xlsx'
      @kids = Kid.includes(:school, :teacher, :mentor, :secondary_mentor, :admin)
      @mentors = Mentor.includes(:school, :schools, :kids, :secondary_kids)
      @kid_mentor_relations = KidMentorRelation.includes(:kid, :mentor, :school)
      @journals = Journal.includes(:kid, :mentor)
      @reviews = Review.includes(:kid)
      @assessments = FirstYearAssessment.includes(:kid, :mentor, :teacher)
      render xlsx: 'show', filename: "futurekids-#{Time.current.strftime('%Y-%m-%d-%H-%M')}.xlsx"
    # normal call redirects to the site wide features
    else
      redirect_to edit_site_url
    end
  end

  def edit; end

  def update
    if @site.update(site_params)
      redirect_to edit_site_url, notice: I18n.t('crud.action.update_success')
    else
      render action: :edit
    end
  end

  private

  def site_params
    params.expect(
      site: %i[footer_address footer_email logo feature_coach
               term_collection_start term_collection_end
               comment_bcc notifications_default_email teachers_can_access_reviews
               kids_schedule_hourly terms_of_use_content
               title css]
    )
  end
end
