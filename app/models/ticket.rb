class Ticket < ActiveRecord::Base
  attr_accessible :number, :event_id, :owner_id
  belongs_to :event
end
