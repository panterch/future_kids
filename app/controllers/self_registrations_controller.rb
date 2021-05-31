class SelfRegistrationsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_if_signed_in
  before_action :redirect_if_disabled

  def new
    @resource = resource_whitelist[params[:type]]&.new
  end

  def create
    @resource = User.new(user_params)
    return render(:new, status: :unauthorized) unless resource_whitelist.values.include? @resource.class

    if params.dig(:terms_of_use, :accepted) == "yes" && @resource.save
      SelfRegistrationsMailer.user_registered(@resource).deliver_now
      redirect_to action: :success, type: @resource.type.downcase
    else
      @terms_of_use_error = true if params.dig(:terms_of_use,:accepted) != "yes"
      render :new
    end
  end

  def success
    if (type = params[:type]) && ['teacher', 'mentor'].include?(type)
      @type = type
    else
      @type = 'teacher'
    end
  end

  def terms_of_use
    @content = Site.load.terms_of_use_content_parsed
  end

  private

  def user_params
    p = params[:teacher].nil? ? mentor_params : teacher_params
    new_password = Devise.friendly_token.first(10)
    p.merge password: new_password, password_confirmation: new_password, state: :selfservice
  end

  def teacher_params
    params.require(:teacher).permit(
      :type, :name, :prename, :email, :phone, :school_id
    )
  end

  def mentor_params
    params.require(:mentor).permit(
      :type, :email, :name, :prename, :sex, :address,
      :city, :photo, :dob, :phone, :school_id, :field_of_study
    )
  end

  def redirect_if_signed_in
    redirect_to new_user_session_path if user_signed_in?
  end

  def redirect_if_disabled
    redirect_to new_user_session_path unless Site.load[:public_signups_active]
  end
  
  def resource_whitelist
    { 'mentor' => Mentor, 'teacher' => Teacher }
  end
end