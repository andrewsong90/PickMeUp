class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_organizer
    @current_organizer ||= Organizer.find(session[:organizer_id]) if session[:organizer_id]
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def genres
    @genre = Genre.all
  end

  helper_method :current_user, :current_organizer, :genres

  # Not authorized if not logged-in as an organizer
  # or logged in but does not own the event
  def authorize_organizer
    if not(current_organizer and (params[:id].nil? or (current_organizer.events.find(params[:id]))))
      redirect_to root_url, alert: "Not authorized"
    end
  end

  # authorize the user
  def authorize_user
    redirect_to root_url, alert: "Not authorized" if current_user.nil?
  end

  # authorize the user for a particular pmu
  def authorize_user_pmu(pmu)
    if not(current_user && pmu && current_user.id == pmu.owner_id)
        redirect_to pmu.event, alert: "Not authorized as the owner of this pmu."
    end
  end
end
