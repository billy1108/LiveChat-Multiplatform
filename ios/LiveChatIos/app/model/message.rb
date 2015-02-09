class Message

  attr_accessor :username, :content, :latitude, :longitude

  def initialize(username = "", content = "", latitude = nil, longitude = nil)
    @username = username
    @content = content
    @latitude = latitude
    @longitude = longitude
  end

end