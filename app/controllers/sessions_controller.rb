class SessionsController < ApplicationController
  #
  def new

  end

  # Log-in
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id

    redirect_to root_url
  end

  # Log-out
  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
