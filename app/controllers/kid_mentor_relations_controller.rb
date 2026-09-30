# frozen_string_literal: true

class KidMentorRelationsController < ApplicationController
  include AdminOnly

  load_and_authorize_resource except: %i[update_kid update_mentor]

  def index
    # a prototype object used for the filter sidebar
    #
    # all fields to filter here have to be present in the sql view
    @kid_mentor_relation = KidMentorRelation.new(filter_params)
    @kid_mentor_relations = @kid_mentor_relations.where(filter_params.to_h.delete_if do |key, val|
      KidMentorRelation.column_names.exclude?(key.to_s) || val.blank?
    end)
    @kid_mentor_relations = if params['order_by'] && valid_order_by?(Kid, params['order_by'])
                              @kid_mentor_relations.reorder(params['order_by'])
                            else
                              @kid_mentor_relations.reorder('kid_name')
                            end

    if params[:format] == 'xlsx'
      return render xlsx: 'index', filename: "kid-mentor-relations-#{Time.current.strftime('%Y-%m-%d-%H-%M')}.xlsx"
    end

    respond_with @kid_mentor_relations
  end

  # inline editing of exit kind and exit date on the index. blank values clear
  # the field. the inputs only allow valid values, so a failing validation is an
  # error: update! raises and Rails answers 422. without a template Rails
  # answers a successful PATCH with 204 No Content on its own
  def update_kid
    kid = Kid.find(params.expect(:kid_id))
    authorize! :update, kid
    kid.update!(params.expect(kid: %i[exit_kind exit_at]))
  end

  def update_mentor
    mentor = Mentor.find(params.expect(:mentor_id))
    authorize! :update, mentor
    mentor.update!(params.expect(mentor: %i[exit_kind exit_at]))
  end

  def destroy
    KidMentorRelation.inactivate(params[:id])
    redirect_back_or_to(kids_url)
  end

  def destroy_all
    KidMentorRelation.reset_all
    redirect_to kid_mentor_relations_url
  end

  protected

  def filter_params
    return {} if params[:kid_mentor_relation].blank?

    params.expect(
      kid_mentor_relation: %i[kid_exit_kind mentor_exit_kind mentor_ects admin_id school_id simple_term]
    )
  end
end
