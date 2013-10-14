class EventsController < ApplicationController

  include EventsHelper

  before_filter :authorize_organizer, only: [:new, :edit, :update, :create, :destroy]

  class UnknownFileType < StandardError
  end

  # The methods below (help, pmu_introduction, team_introduction) are dummy actions to render the views.
  def help
  end

  def pmu_introduction
  end

  def team_introduction
  end

  #This method is to verify the ticket S/N input by the user.
  def confirm

    confirmed = false
    tickets=Ticket.where(:event_id => params[:id])
    tickets.each do |ticket|
      if (ticket.number==params[:code])

        # There are two cases for ticket S/N confirmation
        # 1) The ticket is confirmed for the first time
        # 2) If the ticket has been confirmed before, only the owner of that ticket can be confirmed again
        if(ticket.owner_id == -1)
          ticket.update_attributes(:owner_id => current_user.id)
          confirmed=true
          break
        elsif ticket.owner_id == current_user.id
          confirmed=true
          break
        else
        end
      end
    end

    respond_to do |format|
      format.json {render :json => {:confirmed => confirmed} }
    end
  end


  def genre
    @events=Event.where(:genre=>params[:id])
    @genres = Genre.all
  end

  #rescue_from UnknownFileType, :with => :unknown_file_type
  def unknown_file_type
    flash[:notice] = "The file path you provided is not correct"
    redirect_to new_organizer_event_path(current_organizer)
  end

  def unknown_data_exception
    flash[:notice] = "The file that you submitted for your tickets was not able to be parsed into tickets"
    redirect_to new_organizer_event_path(current_organizer)
  end

  # List all the events
  def index
    if params[:organizer_id] # show organizer's events
      @events=current_organizer.events.all
    else
      @events = Event.all # show all events
    end

    end

  # Create event
  def new
    @event = current_organizer.events.new
  end

  # Edit events
  def edit
    @event = current_organizer.events.find(params[:id])
  end

  # update the event. right now only allow the event organizer to update
  # name, description, genre & address of the event
  def update
    @event = current_organizer.events.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(:name => params[:event][:name], :description => params[:event][:description],
                                  :genre => params[:event][:genre], :address => params[:event][:address], :DateTime => params[:event][:DateTime],
                                  :file => "not actual file path")

        format.html { redirect_to organizer_events_path(current_organizer)}
      else
        format.html { render action: "edit" }
      end
    end
  end

  # Show an event
  # TODO: for vu: comment, reduce logic
  def show
    @event=Event.find(params[:id])
    @attendee = current_user
    @original_organizer = @event.organizer
    if current_user && ((@pmu = current_user.get_my_pmu(@event.id)))
      # get all potential pmus with keyword search
      @pmu = current_user.get_my_pmu(@event.id)
      @potential_pmus = @pmu.search(params[:search])

      # remember the state of the previously selected filters
      def remember_state(param_name, param)
        if !param.blank?
          session[param_name] = param
        else
          session[param_name] = nil
        end
      end
      [:friends, :location, :time].each do |param_name|
        remember_state(param_name, params[param_name])
      end
      # apply the filters
      if any_non_empty?([params[:friends], params[:location], params[:time]])
        @potential_pmus = @pmu.apply_filters(params[:friends], params[:location],
          params[:time], @potential_pmus)
      end
      @potential_pmus = @potential_pmus.paginate :page=>params[:page], :per_page => 10
    end
  end

  # Create an event
  def create
    organizer = current_organizer
    @event = organizer.events.new(params[:event])
    begin
      @event.import(@event.file)
    rescue UnknownFileType
      unknown_file_type
      return
    rescue  Exception
      unknown_data_exception
      return
    else
    respond_to do |format|
      if @event.save
        format.html { redirect_to organizer_events_path(organizer),
          notice: 'Event was successfully created.' }
      else

        format.html { render action: "new", notice:"event failure #{@event.errors}" }
      end
    end
   end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    respond_to do |format|
      format.html { redirect_to organizer_events_url(current_organizer) }
    end
  end
end
