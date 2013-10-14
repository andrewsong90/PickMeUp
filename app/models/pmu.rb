class Pmu < ActiveRecord::Base
  # car_sharing: true if this user wants to look for car sharing
  # cab_sharing: true if this user wants to look for cab sharing
  # datetime: date time of this pmu
  # location: location of this pmu
  # owner: user id of the owner of this pmu. many can be linked to a single a pmu.
  # (note: this is quite badly named. should have named user_id instead)
  # pmu_type: string. "car sharing" if the owner is driving. "cab sharing" if the owner is organizing a cab sharing
  #  "uncommitted" otherwise when the user is not in any sharing yet.
  # max_people => integer => maximum number of people who can share in. default = -1 when pmu_type = "uncommitted"
  # completed => boolean => whether this pmu is completed.

  attr_accessible :cab_sharing, :car_sharing, :datetime, :latitude,
    :location, :longitude, :owner_id, :pmu_type, :max_people, :completed, :event_id

  # date, time & location
  # to show where & when this user is starting
  validates_presence_of :datetime
  validates_presence_of :location

  # each pmu belongs to an event
  belongs_to :event

  # a pmu has many associated users who are participating in this pmu
  has_many :user_pmus, dependent: :destroy
  has_many :users, :through => :user_pmus

  # a pmu has many requesting users who want to join in this pmu
  has_many :requesting_user_pmus, dependent:  :destroy
  has_many :requesting_users, :through => :requesting_user_pmus, :source => :user

  # each pmu has an owner who created the PMU object
  belongs_to :owner, :class_name => "User"

  # geocoder gem - changing from address to latitude & longitude
  geocoded_by :location
  after_validation :geocode, :if => :location_changed?

  # global Constant for PMU model
  PMU_CarShare = 0
  PMU_CarDrive = 1
  PMU_CarRide = 2
  PMU_CabShare = 3
  PMU_NotShare = 4
  PMU_CabShare_CarRide=5

  after_initialize :default_values
  before_save :validate_pmu

  # default values for pmu_type, max people & completed
  def default_values
    self.pmu_type ||= "uncommitted"
    self.completed ||= false
    self.max_people ||= 1
  end

  # Check if pmu is valid
  def validate_pmu

    availability_constraint = (self.max_people - self.users.size) >= 0

    if self.is_driving?
      if (self.cab_sharing == false and self.car_sharing == true and availability_constraint)
        return true
      else
        raise "pmu attributes for car sharing are not correct. please check"
      end

    elsif (self.is_cab_sharing? and self.cab_sharing == true and availability_constraint)
      return true

    elsif (self.is_uncommitted? and availability_constraint)
      return true
    end

    raise "pmu attributes invalid; check your pmu attributes."
  end

  # if the pmu_type is "uncommitted" => available = false
  # if the pmu_type is "car sharing" => available = max_number - users > 0
  # if the pmu_type is "cab sharing" => available = max_number - users > 0
  def available?
    if self.is_uncommitted?
      return false
    else
      return (self.max_people - self.users.size) > 0
    end
  end

  # return whether this pmu is driving
  def is_driving?
    return self.pmu_type == "car sharing"
  end

  # return whether this pmu is about cab sharing
  def is_cab_sharing?
    return self.pmu_type == "cab sharing"
  end

  # return whether this pmu is committed
  def is_committed?
    return self.is_driving? || self.is_cab_sharing?
  end

  # return whether this pmu is uncommitted
  def is_uncommitted?
    return self.pmu_type == "uncommitted"
  end

  # who create the pmu
  def  pmu_owner
    return User.find(owner)
  end

  # check if the user is the owner of this pmu
  def is_owner? (user)
    return user.id == self.owner
  end

  # destination of pmu is the event destination
  def destination
    return self.event.address
  end

  # Based on the parameter, the boolean flags and the pmu_type will be defined
  def set_Pmu_type(choice)
    if (choice == Pmu::PMU_CabShare_CarRide)
      self.cab_sharing = true
      self.car_sharing = true
    elsif (choice == Pmu::PMU_NotShare)
      self.cab_sharing = false
      self.car_sharing = false
    elsif (choice == Pmu::PMU_CabShare)
      self.cab_sharing = true
      self.car_sharing = false
    elsif (choice == Pmu::PMU_CarRide)
      self.cab_sharing = false
      self.car_sharing = true
    else
      self.cab_sharing = false
      self.car_sharing = true
      self.pmu_type = "car sharing"
    end
  end

  # create a new pmu based on these parameters
  # TODO: make this into a transaction
  def self.create_new_pmu(max_people, event_id, location, owner_id, datetime, choice)
    pmu = Pmu.new(:max_people => max_people, :event_id => event_id, :location => location,
                :owner_id => owner_id, :datetime => datetime)

    pmu.default_values
    pmu.set_Pmu_type(choice)

    if pmu.save
      user_pmu = UserPmu.new(:user_id => owner_id, :pmu_id => pmu.id, :location => pmu.location,
                             :latitude => pmu.latitude, :longitude => pmu.longitude, :datetime => pmu.datetime)

      return user_pmu.save
    end

    return false
  end

  # look up other pmu objects that are
  # compatible with this pmu
  # for example, if the user's pmu has cab sharing, show all pmu
  # with the cab sharing flags or is available for cab sharing
  #
  # only the owner of the pmu can retrieve the pmu list
  def get_potential_pmus
    if self.is_driving? # if this user is driving
      return Pmu.where("owner_id <> ? and pmu_type = 'uncommitted' and car_sharing = ? and event_id = ? ",
                       self.owner_id, true, self.event_id)

    elsif self.is_cab_sharing? # if this user is proposing a cab drive
      return Pmu.where("owner_id <> ? and pmu_type = 'uncommitted' and cab_sharing = ? and event_id = ?",
                       self.owner_id, true, self.event.id)

    else # if this user is uncommitted
      result = []
      car_pmu = if (self.car_sharing) then
        Pmu.where("owner_id <> ? and pmu_type = 'car sharing' and event_id = ?",
                  self.owner_id, self.event_id) else [] end

      car_pmu.each do |pmu|
        if pmu.available?
          result.append(pmu)
        end
      end

      cab_pmu = if (self.cab_sharing) then
        Pmu.where("owner_id <> ? and pmu_type = 'cab sharing' and event_id = ?",
                  self.owner_id, self.event_id) else [] end

      cab_pmu.each do |pmu|
        if pmu.available?
          result.append(pmu)
        end
      end

      uncommitted_pmus = if (self.cab_sharing) then
        Pmu.where("owner_id <> ? and pmu_type = 'uncommitted' and cab_sharing = ? and event_id = ?",
                  self.owner_id, true, self.event_id) else [] end

      result = result + uncommitted_pmus
      return result
    end
  end

  # search for potential pmus with some keywords for name
  def search(search)
    if search
      matches = User.where('name LIKE ?', "%#{search}%")
      match_ids = Set.new
      matches.each do |match|
        match_ids.add(match.id)
      end
      search_results = []
      self.get_potential_pmus.each do |pmu|
        if match_ids.include? pmu.owner_id
          search_results.append(pmu)
        end
      end
      return search_results
    else
      self.get_potential_pmus
    end
  end

  # All filters
  def apply_filters(friends, distance, time, pmus)
    # Distance filter: rejecting pmus beyond certain distance
    pmus = pmus.reject {|pmu| pmu.distance_from(self) > distance.to_f} if !distance.blank?

    # Time filter: rejecting pmus beyond certain time range
    pmus = pmus.reject {|pmu|
      Time.diff(Time.parse(self.datetime),Time.parse(pmu.datetime),"%h")[:diff].to_f > time.to_f} if !time.blank?

    # Friend fitler: rejecting pmus not in facebook friend list
    if !friends.blank?
      friend_list = self.owner.facebook.get_connections("me","friends", fields: "id")
      friend_ids = Set.new
      friend_list.each do |friend|
        friend_ids.add(friend["id"].to_i)
      end
      pmus.each do |pmu|
        pmus = pmus.reject {|pmu| !friend_ids.include? pmu.owner.uid.to_i}
      end
    end
    return pmus
  end

  # add the user with this user id to this pmu
  # return true if successful. false otherwise.
  def add_user(user_id)
    user = User.find(user_id)

    # delete the user's pmu
    pmu = Pmu.where("event_id = ? AND owner_id = ?", self.event_id, user.id).first

    # TODO: make this into a transaction

    user_pmu = UserPmu.new(:user_id => user.id, :pmu_id => self.id, :location => pmu.location,
                            :latitude => pmu.latitude, :longitude => pmu.longitude, :datetime => pmu.datetime)

    if user_pmu.save
      pmu.destroy
      user.clear_pmu_requests(self.event_id)
      return true
    end

    return false
  end

  # create new cab request
  # TODO: unit test
  def create_new_cab_trip(user_id)
    self.pmu_type = "cab sharing"
    return self.save && self.add_user(user_id)
  end

  # add the user with thus user id to the requesting user list of this pmu
  # return true if successful. false otherwise.
  def add_requesting_user(user_id)
    requesting_user_pmu = RequestingUserPmu.new(:user_id => user_id, :pmu_id => self.id)
    return requesting_user_pmu.save
  end

  # remove the user from the requesting user list
  # return true if successful. false otherwise.
  def remove_requesting_user(user_id)
    requesting_user_pmu = RequestingUserPmu.where("user_id = ? AND pmu_id = ?", user_id, self.id)
    if requesting_user_pmu.nil? == false and requesting_user_pmu.first.destroy
      return true
    end
    return false
  end

  # remove the user with this user id from this pmu
  def remove_user(user_id)
    user_pmu = UserPmu.where("user_id = ? AND pmu_id = ?", user_id, self.id)

    if user_pmu.nil? == false and user_pmu.first.destroy
      return true
    end

    return false
  end

  # gives datetime in nice string format
  def format_datetime
    date_time = Time.parse(self.datetime)

    return date_time.strftime('%a, %b-%d-%Y at %I:%M %p %z')
  end
end
