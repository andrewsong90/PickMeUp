# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :pmu do |f|
      f.cab_sharing false
      f.car_sharing true
      f.datetime "2013-05-22 03:22:42.769647"
      f.location 'MIT, Cambridge, MA'
      f.owner_id 1
      f.max_people 5
      f.event_id 1
  end
end
