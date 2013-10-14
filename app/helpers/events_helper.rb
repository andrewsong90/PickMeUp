module EventsHelper
  def display_text(pmu)
    if pmu.is_driving?
      return "<strong>" + pmu.owner.name + "</strong>" + " is driving. "
    elsif pmu.is_cab_sharing?
      return pmu.owner.name + " is organizing a cab sharing. "
    elsif pmu.car_sharing == true and pmu.cab_sharing == true
      return pmu.owner.name + " is looking for a car sharing trip or a cab sharing trip. "
    elsif pmu.car_sharing == true
      return pmu.owner.name + " is looking for a car sharing trip. "
    elsif pmu.cab_sharing == true
      return pmu.owner.name + " is looking for a cab sharing trip. "
    else
      return pmu.owner.name + " is not looking for any arrangement. "
    end
  end

  # helper method used in events/show_user_committed.html to format text for car driver
  def format_text_driving_owner(user)
    return user.name + " is driving."
  end

  # helper method used in events/show_user_committed.html to format text for car rider
  def format_text_driving_participant(user)
    return user.name + " is riding."
  end

  # helper method used in the events/show_user_committed.html to format text for cab organizer
  def format_text_cab_organizer(user)
    return user.name + " is organizing the cab trip."
  end

  # helper method used in the events/show_user_committed.html to format text for cab participants
  def format_text_cab_participant(user)
    return user.name + " is participating in the cab trip."
  end

  # helper method used in the events/show_user_uncommitted to format text for cab proposer
  def format_text_cab_proposer(user)
    return user.name + " wants to propose a new cab trip."
  end

  def format_confirmation_status(user, pmu)
    if user.get_confirmation_status(pmu)
      return "Confirmed"
    else
      return "Not Confirmed"
    end
  end
end
