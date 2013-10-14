class Event < ActiveRecord::Base

  # note: rohan is working on this to add another column (EventBriteId)
  attr_accessible :name, :description, :genre, :file, :address, :organizer_id, :DateTime, :filepicker_url, :eventbrite_id

  attr_accessor :file

  # Validation
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :filepicker_url
  validates_presence_of :genre
  validates_presence_of :file
  validates_presence_of :DateTime

  # Associations
  has_many :tickets, dependent: :destroy
  has_many :pmus, dependent: :destroy
  belongs_to :organizer

  # Geocode to get location
  geocoded_by :address
  after_validation  :geocode, :if => :address_changed?

  # Import csv of ticker numbers
  def import(file)
    spreadsheet = Event.open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
        self.tickets.build(row.to_hash)
     end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
      else  raise UnknownFileType.new(File.extname(file.original_filename), file.original_filename)
    end
  end

  def self.importEventBrite(event_id, genre, description, location, date, photo, organizer_id, name, tickethash)

    organizer = Organizer.find(organizer_id)

    result=  Event.find_all_by_eventbrite_id(event_id)
    if result.count !=0
      return
    end
    event = organizer.events.new eventbrite_id: event_id, genre: genre,
                                  description: description, address: location, DateTime: date, filepicker_url: photo, name: name

    event.file = "no file"

    if event.filepicker_url.nil?
      event.filepicker_url = "http://wildbunchadventures.files.wordpress.com/2011/12/enjoying_party_vector-1920x1200.jpg"
    end
    event.save

    tickethash.each do |ticket|
       number=ticket["ticket"]["id"]
       @ticket=event.tickets.new(number: number)
      @ticket.save
    end
  end


  # Return nice datetime
  def format_datetime
    date_time = Time.parse(self.DateTime)

    return date_time.strftime('%a, %b-%d-%Y at %I:%M %p')
  end

end
