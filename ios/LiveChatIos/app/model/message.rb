class Message

  attr_accessor :username, :content

  def initialize(username = "", content = "")
    @username = username
    @content = content
  end

end