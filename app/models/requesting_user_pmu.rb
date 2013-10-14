class RequestingUserPmu < ActiveRecord::Base
  attr_accessible :pmu_id, :user_id

  belongs_to :pmu
  belongs_to :user
end
