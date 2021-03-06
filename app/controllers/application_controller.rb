class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    keys = [
      :email,
      :first_name,
      :last_name,
      :password,
      :password_confirmation,
      :current_password
    ]

    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(keys)
    end
    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(keys)
    end
  end

  def check_permissions(resource)
    unless current_user.can_modify?(resource)
      if request.path.include?('api')
        render json: {
          message: 'You do not have permission to do that'
        }, status: :unauthorized
      else
        flash[:error] = 'You do not have permission to do that. Please login '\
                        'with an account that has that permission.'
        redirect_to root_path
      end
    end
  end
end
