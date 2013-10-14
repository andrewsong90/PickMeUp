class OrganizersController < ApplicationController
  # TODO: authentication

  def new
    @organizer = Organizer.new
  end

  def create
    @organizer = Organizer.new(params[:organizer])
    if @organizer.save

      session[:organizer_id] = @organizer.id
      redirect_to root_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end

  def import_event_brite
    # this will add all the events from event brite to our database
    current_organizer.listEvents

    redirect_to organizer_events_path(current_organizer)
  end

end
