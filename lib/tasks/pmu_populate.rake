namespace :db do
  desc "Erase and fill pmu database"
  task :pmu_populate => :environment do
    require 'populator'
    require 'faker'

    # Clear db
    [Pmu,User].each(&:delete_all)

    # Create users
    User.populate 100 do |user|
      user.address = Faker::Address.street_address
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.gender = ['male','female']
      user.phone = Faker::PhoneNumber.cell_phone
    end

    # Create pmus
    Pmu.populate 200 do |pmu|
      pmu.cab_sharing = [true,false]
      pmu.car_sharing = [true,false]
      pmu.datetime = rand(-30..-3).days.ago
      pmu.location = Faker::Address.street_address
      pmu.latitude = Faker::Address.latitude
      pmu.longitude = Faker::Address.longitude
      pmu.owner_id = rand(1..100)
      pmu.pmu_type = ['car sharing', 'cab sharing', 'uncommitted']
      pmu.max_people = [1, 2, 3, 4, 5]
      pmu.completed = false
      pmu.event_id = [1,2]
    end

    # Create a user nearby my location
    [["100004756772283",'Andrew Song'],["100001262656613",'Minh Tue']].each do |friend|
      User.create(
        address: Faker::Address.street_address,
        name: friend[1],
        email: Faker::Internet.email,
        gender: 'male',
        phone: Faker::PhoneNumber.cell_phone,
        uid: friend[0]
        )
    end

    # Create pmu for a nearby driver
    Pmu.create(
      cab_sharing: false,
      car_sharing: true,
      datetime: rand(-30..0).days.ago,
      location: 'Central Square, Cambridge, MA',
      owner_id: User.last.id-1,
      pmu_type: 'car sharing',
      max_people: 5,
      completed: false,
      event_id: 1
      )

    # Create pmu for a nearby driver
    Pmu.create(
      cab_sharing: false,
      car_sharing: true,
      datetime: -2.hours.ago,
      location: 'Harvard Square, Cambridge, MA',
      owner_id: User.last.id,
      pmu_type: 'car sharing',
      max_people: 5,
      completed: false,
      event_id: 1
      )
  end
end
