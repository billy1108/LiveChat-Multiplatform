class MessageThreadController < UIViewController
  extend IB

  attr_accessor :username, :messages

  outlet :iv_user_profile, UIImageView
  outlet :tf_new_message, UITextField
  outlet :bottomConstraint, NSLayoutConstraint
  outlet :messagesCollectionView, UICollectionView


  def viewDidLoad
    super
    @messages = []
    setupKeyboardNotifications
  end

  def viewWillAppear(animated)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
  end

  def viewDidDisappear(animated)
    NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  end

  def setupKeyboardNotifications
    tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:"hide_keyboard")
    tapGesture.delegate = self
    self.view.addGestureRecognizer(tapGesture)
  end

  #MARK - ACTIONS

  def send_message
    p "send_messague"
    @socketIO.sendMessage(tf_new_message.text)
  end

  def goToBottomCollectionView
    p "goToBottomCollectionView"
  end

  def hide_keyboard
    tf_new_message.resignFirstResponder
  end

  #MARK: - Notification Handler

  def keyboardDidShow(notification)
    info = notification.userInfo
    keyboardFrame = info[UIKeyboardFrameEndUserInfoKey].CGRectValue
    UIView.animateWithDuration(0.5, animations: lambda{
      bottomConstraint.constant = keyboardFrame.size.height
    }, completion: lambda{  |bool|
      goToBottomCollectionView
    })
  end

  def keyboardWillHide(notification)
    info = notification.userInfo
    keyboardFrame = info[UIKeyboardFrameEndUserInfoKey].CGRectValue
    UIView.animateWithDuration(0.1, animations: lambda{
      bottomConstraint.constant = 0.0
    }, nil)
  end

  #MARK: - UICollectionViewDataSource

  def numberOfSectionsInCollectionView(collectionView)
    1
  end
    
  def collectionView(collectionView, numberOfItemsInSection: section)
    @messages.count
  end
    
  def collectionView(collectionView , cellForItemAtIndexPath: indexPath )
    messagesCollectionView.collectionViewLayout.invalidateLayout
    cell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageContentView", forIndexPath:indexPath)
    cell.setMessage(@messages[indexPath.row])
    cell
  end

  def collectionView(collectionView, layout: collectionViewLayout,sizeForItemAtIndexPath: indexPath)
    height = MessageViewCell.heightForCellWithMessage(messages[indexPath.row].content)
    collectionView.collectionViewLayout.invalidateLayout
    CGSizeMake(UIScreen.mainScreen.bounds.width, CGFloat(height))
  end

end