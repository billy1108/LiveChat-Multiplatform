class MessageThreadController < UIViewController
  extend IB

  attr_accessor :username, :socket, :messages

  outlet :iv_user_profile, UIImageView
  outlet :tf_new_message, UITextField
  outlet :bottomConstraint, NSLayoutConstraint
  outlet :messagesCollectionView, UICollectionView

  def viewDidLoad
    super
    setupSocket
    setupElements
    self.navigationController.navigationBar.translucent = false
    @messages = []
    setupKeyboardNotifications
  end

  def viewWillAppear(animated)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
  end

  def viewDidDisappear(animated)
    p "dismiss"
    NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    @socket.emit('disconnect')
  end

  def setupSocket
    SIOSocket.socketWithHost("http://localhost:3000", response: lambda {  |socket|
      @socket = socket
      @socket.emit( 'add user', args: [@username] )
    })
  end

  def setupElements
    tf_new_message.delegate = self
  end

  def setupKeyboardNotifications
    tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:"hide_keyboard")
    tapGesture.delegate = self
    self.view.addGestureRecognizer(tapGesture)
  end

  #MARK - ACTIONS

  def sendMessage
    @socket.emit('new message', args: [tf_new_message.text])
    tf_new_message.text = ""
    p "envie"
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

  #MARK - DELEGATES
  def textFieldDidBeginEditing textField
    @socket.emit('typing')
  end

  def textFieldEndEditing textField
    @socket.emit('stop typing')
  end

end