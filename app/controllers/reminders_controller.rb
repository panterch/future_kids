class RemindersController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  # update is used to trigger the mail delivery
  def update
    resource.deliver_mail
    update!(:notice => "Erinnerung wird zugestellt and #{resource.recipient}") do
      collection_url
    end
  end

end
