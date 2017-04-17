class KidMentorRelationsController < ApplicationController
  include AdminOnly
  load_and_authorize_resource

  def index
    # a prototype object used for the filter sidebar
    #
    # all fields to filter here have to be present in the sql view
    @kid_mentor_relation = KidMentorRelation.new(filter_params)
    @kid_mentor_relations = @kid_mentor_relations.where(filter_params.to_h.delete_if { |_key, val| val.blank? })
    if params['order_by']
      @kid_mentor_relations = @kid_mentor_relations.reorder(params['order_by'])
    else
      @kid_mentor_relations = @kid_mentor_relations.reorder('kid_name')
    end

    if 'xlsx' == params[:format]
      return render xlsx: 'index'
    else
      respond_with @kid_mentor_relations
    end
  end

  def destroy
    KidMentorRelation.inactivate(params[:id])
    redirect_back(fallback_location: kids_url)
  end

  def destroy_all
    KidMentorRelation.reset_all
    redirect_to kid_mentor_relations_url
  end

  protected

  def filter_params
    return {} unless params[:kid_mentor_relation].present?
    params.require(:kid_mentor_relation).permit(
      :kid_exit_kind, :mentor_exit_kind, :admin_id, :school_id, :simple_term
    )
  end
end
