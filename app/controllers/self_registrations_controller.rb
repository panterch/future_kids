class SelfRegistrationsController < ApplicationController
  # load_and_authorize_resource

  skip_before_action :authenticate_user!
  before_action :redirect_if_signed_in

  def new
    resource_whitelist = { 'mentor' => Mentor, 'teacher' => Teacher }
    @resource = resource_whitelist[params[:type]]&.new
  end

  def create
    @resource = User.new(user_params)
    if @resource.save
      SelfRegistrationsMailer.user_registered(@resource).deliver_now
      redirect_to action: :success
    else
      render :new
    end
  end

  def success; end

  private

  def user_params
    p = params[:teacher].nil? ? params.require(:mentor) : params.require(:teacher)
    p = p.permit(
      :type, :email, :name, :prename, :sex, :address, :photo, :dob, :phone, :school, :field_of_study
    )
    new_password = Devise.friendly_token.first(10)
    p.merge password: new_password, password_confirmation: new_password, state: :unproven
  end

  def redirect_if_signed_in
    redirect_to new_user_session_path if user_signed_in?
  end
end