class MessageViewCell < UITableViewCell
  extend IB

  outlet :user_picture, UIImageView
  outlet :lbl_day, UILabel
  outlet :lbl_time, UILabel
  outlet :lbl_text, UILabel

  def setMessageCell(message)
    
  end
  
end