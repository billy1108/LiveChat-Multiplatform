class MessageViewCell < UITableViewCell
  extend IB

  outlet :user_picture, UIImageView
  outlet :lbl_day, UILabel
  outlet :lbl_time, UILabel
  outlet :lbl_text, UILabel

  def setMessage(message)
    lbl_day.text = "Jueves"
    lbl_time.text = "Tiempo"
    lbl_time.setTranslatesAutoresizingMaskIntoConstraints(false)
    lbl_day.setTranslatesAutoresizingMaskIntoConstraints(false)
    lbl_text.setTranslatesAutoresizingMaskIntoConstraints(false)
    lbl_text.text = message.content
  end
  
end