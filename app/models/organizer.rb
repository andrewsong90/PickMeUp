class Organizer < ActiveRecord::Base
  has_secure_password
  attr_accessible :affiliation, :email, :name, :password, :password_confirmation, :eventbrite_id
  has_many :events, dependent: :destroy

  # Validation
  validates_presence_of :email
  validates_uniqueness_of :email, case_sensitive: false
  validates :password, presence: true, length: { minimum: 6 }
  validates_presence_of :password_confirmation
  
  # note: more comments
  def listEvents
    eb_client = EventbriteClient.new(app_key: Eventbrite_CONFIG["app_key"], user_key:Eventbrite_CONFIG["user_key"] )


    res=eb_client.organizer_list_events({id: self.eventbrite_id})
    @events=res.parsed_response["events"]

    @events.each do |superevent|
      begin
        organizer_id=self.id
        event=superevent["event"]
        title= event["title"]
        genre=event["category"]
        id=event["id"]
        photo=event["logo"]
        descriptionunstripped=event["description"]
        description=ActionView::Base.full_sanitizer.sanitize(descriptionunstripped)
        venue=event["venue"]
        address=venue["address"]
        city=venue["city"]
        postal_code=venue["postal_code"]
        country=venue["country"]
        date=event["start_date"]
        tickets=event["tickets"]
        location= address+ " " +city + " " + postal_code + " " + country

        Event.importEventBrite(id, genre, description, location, date, photo,organizer_id,title, tickets)

      rescue Exception => e
        # TODO: add some loggings here
        next
      end
    end



  end
end
