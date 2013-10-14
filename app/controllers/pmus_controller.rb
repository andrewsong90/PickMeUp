class PmusController < ApplicationController
  # this class has all the methods that return JSON data from requesting users

  # TODO: authentication for index +confirm later
  before_filter :authorize_user, only: [:show, :new, :create, :add_requesting_user, :create_new_cab_trip]

  before_filter( only: [:edit, :update, :add_user, :remove_user, :remove_requesting_user, :destroy]) {
      |c| c.authorize_user_pmu Pmu.find(params[:id]) }


  # GET: return the list of all pmus relevant to this pmu
  def index

    # This is the pmu that has been joined
    @joined_pmus=Array.new
    requests=current_user.user_pmus #UserPmu.where(:user_id=> current_user.id)
    requests.each do |request|
      pmu=Pmu.find(request.pmu_id)
      if(pmu.pmu_type!="uncommitted")
        @joined_pmus.push(pmu)
      end

    end

    # This is the pmu that has been requested
    @requested_pmus=Array.new
    requests=current_user.requesting_user_pmus #RequestingUserPmu.where(:user_id=> current_user.id)
    requests.each do |request|
      pmu=current_user.myPmus.find_by_event_id(Pmu.find(request.pmu_id).event.id)
      @requested_pmus.push(pmu)
    end

    # This is the pmu owned by the user (uncommitted, cab-sharing)
    @uncommitted_pmus=Array.new
    requests=current_user.myPmus.where(:pmu_type => "uncommitted")
    requests.each do |request|
      if !(@requested_pmus.include?(request))
        @uncommitted_pmus.push(request)
      end
    end
  end

  #Shows the PMU of the corresponding ID
  def show
    @pmu=Pmu.find(params[:id])
    @event=Event.find(params[:event_id])
  end

  #Creates new PMU object
  def new
    @event=Event.find(params[:event_id])

    if current_user.has_existing_pmu?(@event.id)
      redirect_to @event
    end
  end

  # create a new pmu with these attributes. the owner of the pmu is the current user.
  def create
    #This variable sums up the choices made by the users on the pmus/new page and assigns variables based on the value
    choice = params[:sharing_type].to_i+(if(!params[:car_share_type]) then 0 else params[:car_share_type].to_i end)

    respond_to do |format|
      if Pmu.create_new_pmu(params[:max_people],params[:event_id], params[:location], current_user.id,
                            params[:datetime], choice)

        format.html { redirect_to event_path(Event.find(params[:event_id]))}
      else
        format.html { redirect_to new_event_pmu_path(:event_id=>params[:event_id]), :notice => "Failed to create the request!" }
      end
    end
  end

  # Edit the existing PMU
  def edit
    @pmu=Pmu.find(params[:id])
    @event=Event.find(params[:event_id])
  end

  # PUT action to update existing pmu
  def update

    location, datetime, max_people = params[:location], params[:datetime], params[:max_people]

    pmu = Pmu.find(params[:id])

    # If people already have joined this trip, the user should not be able to modify his trip details
    if pmu.users.size > 1
      respond_to do |format|
        format.html {redirect_to event_path(Event.find(params[:event_id])), :notice => "There are other people in this trip! You cannot edit your details"}
      end

    # If there are no people in this trip other than himself, go ahead and chage the details
    else
      #This variable sums up the choices made by the users on the pmus/new page and assigns variables based on the value
      choice = params[:sharing_type].to_i+(if(!params[:car_share_type]) then 0 else params[:car_share_type].to_i end)

      pmu.pmu_type="uncommitted"
      pmu.set_Pmu_type(choice)

      respond_to do |format|
        # When the update is valid
        if (a=pmu.update_attributes(:location => location, :datetime => datetime, :max_people => max_people)) &&
            (b=(user_pmu=pmu.user_pmus.where(:user_id => current_user.id).first).update_attributes(:location => pmu.location, :latitude => pmu.latitude, :longitude => pmu.longitude ))

          format.html { redirect_to event_path(Event.find(params[:event_id]))}
          format.json { render :json => { :msg => "success"} and return}
        #When the update is invalid
        else
          format.html { redirect_to event_path(Event.find(params[:event_id])), :notice => "Wrong Information!"}
          format.json { render :json => { :msg => "error" } and return}
        end
      end
    end

  end

  # GET, POST: add the user to this pmu
  # remove the previous pmu for this event for this user and add this user to this pmu
  def add_user
    pmu = Pmu.find(params[:id])

    requesting_user = User.find(params[:user_id])

    if requesting_user.in?(pmu.users)
      flash_msg = "You have already added this user to this trip."
    else
      added = pmu.add_user(requesting_user.id)

      flash_msg = if added then "You have successfully added " + requesting_user.name else
                  "Unknown errors. Please contact admin."  end
    end

    respond_to do |format|
      format.html do
        flash[:notice] = flash_msg

        redirect_to pmu.event
      end
    end
  end

  # GET/POST: add the requesting user to this pmu
  def add_requesting_user
    pmu = Pmu.find(params[:id])

    if current_user.own_pmu?(pmu) || current_user.has_requested_pmu?(pmu)
      redirect_to pmu.event
    else
      added = pmu.add_requesting_user(current_user.id)

      respond_to do |format|
        format.html do
          flash_msg = if added then "You are successfully added to the requesting list of " + pmu.owner.name else
            "Unknown errors. Please contact admin."  end

          flash[:notice] = flash_msg

          redirect_to pmu.event
        end
      end
    end
  end

  # GET/POST: create a new cab trip for this user + another user
  def create_new_cab_trip
    pmu = Pmu.find(params[:id])
    new_cab_trip_created = pmu.create_new_cab_trip(params[:user_id])

    flash_msg = if new_cab_trip_created then "New cab trip created!" else "Unknown error. Please contact admin" end

    respond_to do |format|
      format.html do
        flash[:notice] = flash_msg

        redirect_to pmu.event
      end
    end
  end

  # DELETE: remove the user from this pmu
  def remove_user
    pmu = Pmu.find(params[:id])
    removed = pmu.remove_user(params[:user_id])

    flash_msg = if removed then "User removed from this trip successfully."
                else "User removed unsuccessfully. Contact admin" end

    respond_to do |format|
      format.html do
        flash[:notice] = flash_msg

        redirect_to pmu.event
      end
    end

  end

  # DELETE: remove the requesting user from this pmu
  def remove_requesting_user
    pmu = Pmu.find(params[:id])
    removed = pmu.remove_requesting_user(params[:user_id])

    flash_msg = "User removed unsuccessfully. Unknown errors."

    if removed
      flash_msg = "User removed successfully from requesting list."
    end

    respond_to do |format|
      format.html do
        flash[:notice] = flash_msg

        redirect_to pmu.event
      end
    end
  end

  # DELETE this pmu & clear all the relations
  def destroy
    pmu = Pmu.find(params[:id])

    flash_msg = if pmu.destroy then "Requested cancelled successfully." else "Unknown errors. Please contact admin" end

    respond_to do |format|
      format.html do
        flash[:notice] = flash_msg

        redirect_to pmu.event
      end
    end
  end

  # POST confirm the attendance of the user with the associated confirmation code
  def confirm
      latitude, longitude, datetime, pmu_code=params[:latitude], params[:longitude], params[:datetime], params[:pmu_code]

      user_pmu,valid_loc,valid_time = UserPmu.validate_pmu_code(pmu_code,latitude,longitude,datetime)

      msg = ""

      if user_pmu.nil?
        msg = "Code incorrect. Please retype."
      else
        # If the user is not at the valid location
        if !valid_loc
          msg = "You are far from your expected location! Please move closer to your proposed location"
        # if the user is not within the valid time
        elsif !valid_time
          msg= "It's not your proposed time!"
        # if all the conditions are satisfied
        else
          msg = "Confirmed"
          user_pmu.confirm(latitude, longitude, datetime)
        end
      end

      render :text=> msg
  end
end