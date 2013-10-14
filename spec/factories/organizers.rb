# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organizer do |f|
    f.name "Vu Le"
    f.sequence(:email) { |n| "test#{n}@mit.edu"}
    f.password "hellomit"
    f.password_confirmation "hellomit"
    f.affiliation "MIT"
  end
end
