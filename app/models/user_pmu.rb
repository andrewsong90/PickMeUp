class UserPmu < ActiveRecord::Base
  attr_accessible :pmu_id, :user_id, :latitude, :longitude, :location, :datetime, :code, :confirmed

  # turning lat + lon into actual address using geocoder gem
  reverse_geocoded_by :latitude, :longitude, :address => :location
  after_validation :reverse_geocode, :if => :latitude_changed? || :longitude_changed?

  belongs_to :pmu
  belongs_to :user

  validates_uniqueness_of :code, case_sensitive: true

  before_save :validate_user_pmu

  def validate_user_pmu
    if self.code.blank?
      raise "pmu user code cannot be nil or empty."
    end
  end

  def get_unique_pmu_code
    code = SecureRandom.hex(3)

    while UserPmu.find_by_code(code) != nil
      code = SecureRandom.hex(3)
    end

    return code
  end

  after_initialize :default_values

  # setting the default values for the pmu code
  def default_values
    if self.code.blank?
      self.code = get_unique_pmu_code
      self.confirmed = false
    end
  end

  #Validate the requested PMU condition by comparing the expected location and the current location.
  def self.validate_pmu_code(pmu_code,latitude,longitude,datetime)
    user_pmu=UserPmu.find_by_code(pmu_code)

    valid_loc=false
    valid_time=true

    if !user_pmu.nil?
      # The location constraint - User should be within 0.5 miles of the proposed location
      if (distance=user_pmu.distance_from([latitude,longitude]))<0.5
        valid_loc=true
      end
    end

    return [user_pmu,valid_loc,valid_time]
  end

  # Checks whether the user_pmu has been confirmed
  def is_confirmed?
    if self.confirmed == true
      return true
    else
      return false
    end
  end

  # confirm this pmu
  def confirm(latitude, longitude, datetime)
    self.confirmed = true
    self.latitude = latitude
    self.longitude = longitude
    self.datetime = datetime

    self.save
  end
end
