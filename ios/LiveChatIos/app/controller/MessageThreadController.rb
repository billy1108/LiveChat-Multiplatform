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
    SIOSocket.socketWithHost("https://livechat-multiplatform.herokuapp.com/", response: lambda {  |socket|
      @socket = socket
      @socket.emit( 'add user', args: [@username] )
      setupSocketListener
    })
  end

  def setupSocketListener
    @socket.on("new message", callback: lambda{ |data|
      @messages << Message.new(data.first["username"], data.first["message"])
      messagesCollectionView.reloadData
      goToBottomCollectionView
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
    @messages << Message.new(@username, tf_new_message.text)
    messagesCollectionView.reloadData
    tf_new_message.text = ""
    hide_keyboard
    goToBottomCollectionView
  end

  def goToBottomCollectionView
    item = @messages.count - 1
    if (item >= 0)
      index_path = NSIndexPath.indexPathForRow(item, inSection:0)
      messagesCollectionView.scrollToItemAtIndexPath(index_path, atScrollPosition: UICollectionViewScrollPositionBottom, animated: true)
    end
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
    CGSizeMake(UIScreen.mainScreen.bounds.size.width, height)
  end

  #MARK - DELEGATES
  def textFieldDidBeginEditing textField
    @socket.emit('typing')
  end

  def textFieldEndEditing textField
    @socket.emit('stop typing')
  end

end