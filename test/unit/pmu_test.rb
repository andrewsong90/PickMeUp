require 'test_helper'

class PmuTest < ActiveSupport::TestCase
  test "1 - basic validation" do
    pmuone = pmus(:one)
    andrew = users(:andrew)
    dnj_event = events(:dnj_all_software)

    assert_equal andrew.id, pmuone.owner_id
    assert_equal dnj_event.id, pmuone.event_id
    assert_equal "MIT, Cambridge, MA", pmuone.location
    assert_equal 1.5, pmuone.latitude
    assert_equal 1.5, pmuone.longitude
    assert_equal false, pmuone.cab_sharing
    assert_equal true, pmuone.car_sharing
    assert_equal "car sharing", pmuone.pmu_type
    assert pmuone.is_driving?
    assert_equal "Thu, Apr-25-2013 at 06:42 PM -0400", pmuone.format_datetime
    assert_equal 5, pmuone.max_people

    assert andrew.has_own_pmu?(dnj_event.id)
    assert_equal pmuone, andrew.get_own_pmu(dnj_event.id)
    assert andrew.own_pmu?(pmuone)

    vu = users(:vu)
    assert vu.has_own_pmu?(dnj_event.id)
  end

  test "2 - valid fields" do
    pmu = Pmu.new  owner_id: 1, datetime: "2013-04-25 18:42:43", location: "New York", latitude: 1.5, longitude: 1.5,
                   cab_sharing: true, car_sharing: true, max_people: 5, pmu_type: "uncommitted"

    assert pmu.valid?
   end

   test "3 - unavailable when uncommitted" do
    pmuone=pmus(:two)

    assert  !pmuone.available?
  end

  test "4 - unavailable when all people are fulled" do
    pmuone=pmus(:three)

    assert  !pmuone.available?
  end

  test "5 - default" do
    pmuone = Pmu.new event_id: 1, owner_id: 1, datetime: "2013-04-25 18:42:43", location: "New York", latitude: 1.5,
                     longitude: 1.5, cab_sharing: false, car_sharing: false

    assert_equal "uncommitted", pmuone.pmu_type
    assert_equal false, pmuone.completed
    assert_equal 1, pmuone.max_people
  end

  test "6 - add and remove requesting user" do
    pmuone = pmus(:one)

    andrew = users(:andrew)
    vu = users(:vu)

    pmuone.add_requesting_user(vu.id)

    assert_equal 1, pmuone.requesting_users.size
    assert vu.has_requested_pmu?(pmuone)

    pmuone.remove_requesting_user(vu.id)

    assert_equal 0, pmuone.requesting_users.size
    assert !vu.has_requested_pmu?(pmuone)
  end

  test "6b - get potential pmus" do
    pmuone = pmus(:one)
    pmutwo = pmus(:two)
    pmuthree = pmus(:three)

    potential_pmus = pmutwo.get_potential_pmus

    assert_equal 1, potential_pmus.size
    assert_equal pmuone, potential_pmus.first

    # changing settins for pmu two so that we can filter again
    pmutwo.cab_sharing = true
    pmutwo.car_sharing = false

    potential_pmus = pmutwo.get_potential_pmus

    assert_equal 1, potential_pmus.size
    assert_equal pmuthree, potential_pmus.first

    # changing settins for pmu two so that we can filter again
    pmutwo.cab_sharing = true
    pmutwo.car_sharing = true

    potential_pmus = pmutwo.get_potential_pmus

    assert_equal 2, potential_pmus.size

    pmutwo.save

    # testing for the first pmu
    potential_pmus = pmuone.get_potential_pmus
    assert_equal 2, potential_pmus.size
  end

  test "7 - add and remove users" do
    pmuone = pmus(:one)
    dnj_event = events(:dnj_all_software)

    andrew = users(:andrew)
    vu = users(:vu)

    # now, test add user
    pmuone.add_user(vu)

    assert !vu.has_own_pmu?(dnj_event.id)
    assert pmuone.is_committed?
    assert_equal 2, pmuone.users.size
    assert vu.has_committed_pmu?(dnj_event.id)
    assert_equal pmuone, vu.get_committed_pmu(dnj_event.id)

    # now, test remove user
    pmuone.remove_user(vu)

    assert_equal 1, pmuone.users.size
    assert !vu.has_committed_pmu?(dnj_event.id)
  end

  test "8 - search" do
    pmuone = pmus(:one)
    pmutwo = pmus(:two)
    pmuthree = pmus(:three)

    assert_equal pmuone.search(nil), pmuone.get_potential_pmus
    assert_equal pmuone.search('Alex'), [pmutwo]
    assert_equal pmuone.search('Minh'), []
  end

  test "8 - without filters" do
    pmuone = pmus(:one)
    potential_pmus = pmuone.get_potential_pmus

    assert_equal potential_pmus,pmuone.apply_filters(nil, nil, nil, potential_pmus)
    assert_equal [],pmuone.apply_filters(nil, nil, nil,[])
  end

  test "9 - distance filter" do
    pmuone = pmus(:one)
    pmutwo = pmus(:two)
    pmuthree = pmus(:three)
    potential_pmus = pmuone.get_potential_pmus

    assert_equal [pmutwo],pmuone.apply_filters(nil, 2, nil, potential_pmus)
    assert_equal [],pmuone.apply_filters(nil, 0.1, nil,potential_pmus)
    assert_equal [pmutwo,pmuthree],pmuone.apply_filters(nil, 10000, nil,potential_pmus)
  end

  test "9 - time filter" do
    pmuone = pmus(:one)
    pmutwo = pmus(:two)
    pmuthree = pmus(:three)
    potential_pmus = pmuone.get_potential_pmus

    assert_equal [pmutwo],pmuone.apply_filters(nil, nil, 2, potential_pmus)
    assert_equal [],pmuone.apply_filters(nil, nil, 0.5, potential_pmus)
    assert_equal [pmutwo,pmuthree],pmuone.apply_filters(nil, nil, 25, potential_pmus)
  end

  test "9 - combined filter" do
    pmuone = pmus(:one)
    pmutwo = pmus(:two)
    pmuthree = pmus(:three)
    potential_pmus = pmuone.get_potential_pmus

    assert_equal [pmutwo,pmuthree],pmuone.apply_filters(nil, 10000, 25, potential_pmus)
    assert_equal [pmutwo],pmuone.apply_filters(nil, 10000, 2, potential_pmus)
    assert_equal [pmutwo],pmuone.apply_filters(nil, 2, 25, potential_pmus)
    assert_equal [],pmuone.apply_filters(nil, 0.1, 25, potential_pmus)
    assert_equal [],pmuone.apply_filters(nil, 2, 0.5, potential_pmus)
  end
end
