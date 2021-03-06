class IdentitiesController < ApplicationController
  def create
    Identity.find_or_create_from_omniauth(request.env['omniauth.auth'],
                                          current_user)

    redirect_to stored_location_for(:user) || advisees_path
  end
end
