# frozen_string_literal: true

class KidMentorRelationsController < ApplicationController
  include AdminOnly

  load_and_authorize_resource except: %i[update_kid update_mentor]
  include IndexFilters # filter_index

  def index
    @kid_mentor_relations = filter_index(@kid_mentor_relations, kid_mentor_relation_params)
    return if performed?

    # per row: the mentor's avatar, the school link and kid.mentor (used by
    # #inactivatable?) - kid, mentor and admin come from the default scope
    @kid_mentor_relations = @kid_mentor_relations.includes(:school, kid: :mentor,
                                                                    mentor: { photo_attachment: :blob })

    if params[:format] == 'xlsx'
      return render xlsx: 'index', filename: "kid-mentor-relations-#{Time.current.strftime('%Y-%m-%d-%H-%M')}.xlsx"
    end

    respond_with @kid_mentor_relations
  end

  # inline editing of the exit kind, exit term and (kids only) exit reason on
  # the index. a blank value clears the field. the inputs only allow valid
  # values, so a failing validation is an error: update! raises and Rails
  # answers 422. without a template Rails answers a successful PATCH with
  # 204 No Content on its own
  def update_kid
    kid = Kid.find(params.expect(:kid_id))
    authorize! :update, kid
    kid.update!(params.expect(kid: %i[exit_kind exit exit_reason]))
  end

  def update_mentor
    mentor = Mentor.find(params.expect(:mentor_id))
    authorize! :update, mentor
    mentor.update!(params.expect(mentor: %i[exit_kind exit]))
  end

  def destroy
    # the exit selects on the index save in place without redrawing the row,
    # so the button may be out of date: check again before releasing anything
    if @kid_mentor_relation.inactivatable?
      KidMentorRelation.inactivate(params[:id])
      redirect_back_or_to(kids_url, notice: t('flash.kid_mentor_relation_inactivated'))
    else
      redirect_back_or_to(kids_url, alert: t('flash.kid_mentor_relation_not_inactivatable'))
    end
  end

  def destroy_all
    KidMentorRelation.reset_all
    redirect_to kid_mentor_relations_url
  end

  protected

  # all fields to filter here have to be present in the sql view
  def kid_mentor_relation_params
    return {} if params[:kid_mentor_relation].blank?

    params.expect(
      kid_mentor_relation: %i[kid_exit_kind mentor_exit_kind mentor_ects admin_id school_id simple_term]
    )
  end
end
