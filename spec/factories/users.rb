# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do |f|
    f.provider 'facebook'
    f.uid '231321'
    f.name 'Ruby'
    f.oauth_token 'JLKJJLJ'
    f.oauth_expires_at '2013-04-26 01:00:00'
    f.address 'MIT'
    f.email 'ruby@mit.edu'
    f.gender 'male'
    f.phone '123456789'
  end
end
