class MessageThreadController < UIViewController
  extend IB

  attr_accessor :username, :socket

  outlet :iv_user_profile, UIImageView
  outlet :tf_new_message, UITextField
  outlet :bottomConstraint, NSLayoutConstraint
  outlet :messagesCollectionView, UICollectionView


  def viewDidLoad
    super
    setupSocket
    setupElements
    self.navigationController.navigationBar.translucent = false
  end

  def viewWillAppear(animated)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
  end

  def viewDidDisappear(animated)
    NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    @socket.on('disconnect')
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

  #MARK - ACTIONS

  def sendMessage
    @socket.emit('new message', args: [tf_new_message.text])
    tf_new_message.text = ""
    p "envie"
  end

  def goToBottomCollectionView
    p "goToBottomCollectionView"
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

  #MARK - DELEGATES
  def textFieldDidBeginEditing textField
    @socket.emit('typing')
  end

  def textFieldEndEditing textField
    @socket.emit('stop typing')
  end

end