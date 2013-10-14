class User < ActiveRecord::Base
  attr_accessible :address, :name, :oauth_expires_at, :oauth_token, :provider, :uid, :email, :gender, :phone

  attr_accessor :profile_picture


  #Each user has multiple PMUs that he has created
  has_many :myPmus, :class_name => "Pmu", :foreign_key => "owner_id", dependent: :destroy

  #Each user has many to many relationship with PMUs he has joined
  has_many :user_pmus, dependent: :destroy
  has_many :pmus, :through => :user_pmus, dependent: :destroy

  #Each user has many to many relationship with PMUs he has requested to join
  has_many :requesting_user_pmus, dependent:  :destroy
  has_many :requested_pmus, :through => :requesting_user_pmus, :source => :pmu

  # Record user's facebook log-in details
  def self.from_omniauth(auth)
    log_in_user = where(auth.slice(:provider, :uid)).first
    if log_in_user
      log_in_user.name = auth.info.name
      log_in_user.oauth_token = auth.credentials.token
      log_in_user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      log_in_user.email = log_in_user.get_email
      log_in_user.gender = log_in_user.get_gender
      log_in_user.save!
      return log_in_user
    else
      new_user = self.create(
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        oauth_token: auth.credentials.token,
        oauth_expires_at: Time.at(auth.credentials.expires_at),
        )
      new_user.email = new_user.get_email
      new_user.gender = new_user.get_gender
      new_user.save!
      return new_user
    end
  end

  # method to return the facebook object
  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
    block_given? ? yield(@facebook) : @facebook
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    nil # or consider a custom null object
  end

  # get email
  def get_email
    facebook { |fb| fb.get_object('me')['email']}
  end

  # get gender
  def get_gender
    facebook { |fb| fb.get_object('me')['gender']}
  end

  # get own pmu for this event if exists. return nil if not
  def get_own_pmu(event_id)
    pmu = self.myPmus.where(:event_id => event_id)

    if pmu.size > 0
      return pmu.first
    else
      return nil
    end
  end

  # check whether the user owns a pmu for this event
  def has_own_pmu?(event_id)
    if get_own_pmu(event_id)
      return true
    end

    return false
  end

  # check if this user has already requested this pmu
  def has_requested_pmu?(pmu)
    return self.in?(pmu.requesting_users)
  end

  # get the committed pmu for this user if he is in an pmu arrangement with another user. return nil if not.
  def get_committed_pmu(event_id)
    pmu = self.pmus.where(:event_id => event_id)

    if pmu.size > 0
      return pmu.first
    else
      return nil
    end
  end

  def is_joined?(pmu)
    if (pmu.user_pmus.where(:user_id=>self.id).length==0)
      return false
    end

    return true
  end

  # check whether the user is in any existing arrangement for this event
  def has_committed_pmu?(event_id)
    if get_committed_pmu(event_id)
      return true
    end

    return false
  end

  # clear all joining pmu requests for this event
  # TODO: test
  def clear_pmu_requests(event_id)
    self.requested_pmus.each do |pmu|
      if pmu.event_id == event_id
        pmu.remove_requesting_user(self)
      end
    end
  end

  # check whether the user has any existing pmu for this event (whether he owns it, or he is committed with anyone else)
  # TODO: test
  def has_existing_pmu?(event_id)
    return (has_own_pmu?(event_id) || has_committed_pmu?(event_id))
  end

  # return the profile picture of the current user
  def get_profile_picture
    self.profile_picture ||= self.facebook.get_picture("me")
  end

  # return the pmu for this event. if the user has his own pmu, return it. else return the committed pmu
  def get_my_pmu(event_id)
    if self.has_own_pmu?(event_id)
      return self.get_own_pmu(event_id)
    else
      return self.get_committed_pmu(event_id)
    end
  end

  # get the confirmation code for this user for this pmu
  # TODO: test
  def get_confirmation_code(pmu)
    return self.user_pmus.where(:pmu_id => pmu.id).first.code
  end

  # get the confirmation status for this user for this pmu
  # TODO: test
  def get_confirmation_status(pmu)
    return self.user_pmus.where(:pmu_id => pmu.id).first.confirmed
  end

  # check if the current user owns this pmu
  def own_pmu?(pmu)
    return self.id == pmu.owner_id
  end
end
