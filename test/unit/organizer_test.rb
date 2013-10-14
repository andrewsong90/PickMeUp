require 'test_helper'

class OrganizerTest < ActiveSupport::TestCase
  test "test 1 - checking database" do
    organizer = Organizer.first

    assert_equal "Daniel Jackson", organizer.name
  end
end
