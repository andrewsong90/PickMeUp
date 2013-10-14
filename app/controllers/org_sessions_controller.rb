class OrgSessionsController < ApplicationController
  def new
  end

  # This is for creating the session for organizer
  def create
    organizer = Organizer.find_by_email(params[:email])
    if organizer && organizer.authenticate(params[:password])
      session[:organizer_id] = organizer.id
      redirect_to root_url, notice: "Logged in!"
    else
      redirect_to root_url, notice: "Email or password is invalid"
    end
  end

  # This is for destroying the session for organizer
  def destroy
    session[:organizer_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end
