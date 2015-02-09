class MessageViewCell < UICollectionViewCell
  extend IB

  outlet :user_picture, UIImageView
  outlet :lbl_day, UILabel
  outlet :lbl_time, UILabel
  outlet :lbl_text, UILabel

  def setMessage(message)
    p "MESSAGE"
    lbl_day.text = message.username
    today = NSDate.date
    dateFormatter = NSDateFormatter.alloc.init
    dateFormatter.setTimeStyle(NSDateFormatterShortStyle)
    currentTime = dateFormatter.stringFromDate(today)
    lbl_time.text = currentTime
    paragraphStyle = NSMutableParagraphStyle.alloc.init
    paragraphStyle.lineSpacing = 4
    attrString = NSMutableAttributedString.alloc.initWithString(message.content)
    attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
    lbl_text.attributedText  = attrString
  end

  def self.heightForCellWithMessage(message)
    size = CGSizeMake(280, 1000)
    paragraphStyle = NSMutableParagraphStyle.alloc.init
    paragraphStyle.lineSpacing = 4
    attrs = { NSFontAttributeName => UIFont.fontWithName("Helvetica", size:13.0), NSParagraphStyleAttributeName => paragraphStyle }
    bounding = message.boundingRectWithSize(size, options: NSStringDrawingUsesLineFragmentOrigin, attributes: attrs, context: nil)
    return (bounding.size.height + 50)
  end

  
end