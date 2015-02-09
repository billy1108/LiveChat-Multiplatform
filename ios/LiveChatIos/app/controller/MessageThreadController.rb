class MessageThreadController < UIViewController
  extend IB

  attr_accessor :username, :socket, :messages, :location

  outlet :shareButton, UIButton
  outlet :tf_new_message, UITextField
  outlet :bottomConstraint, NSLayoutConstraint
  outlet :messagesCollectionView, UICollectionView

  def viewDidLoad
    super
    NSLog("@location") 
    NSLog("-#{@location.coordinate.longitude}-") 
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
    @socket.emit('user left')
  end

  def setupSocket
    SIOSocket.socketWithHost("http://localhost:3000/", response: lambda {  |socket|
      @socket = socket
      @socket.emit( 'add user', args: [@username] )
      setupSocketListeners
      SVProgressHUD.dismiss
    })
  end

  def setupSocketListeners
    setupMessageListener
    setupLocationListener
  end

  def setupMessageListener
    @socket.on("new message", callback: lambda{ |data|
      @messages << Message.new(data.first["username"], data.first["message"])
      messagesCollectionView.reloadData
      p @messages
      goToBottomCollectionView
    })
  end

  def setupLocationListener
    @socket.on("new message map", callback: lambda{ |data|
      p "DATA #{data}"
      p "username #{data.first["username"]}"
      p "latitude #{data.first["latitude"]}"
      @messages << Message.new(data.first["username"],"", data.first["latitude"], data.first["longitude"])
      p "SILENCIO FORNICADORA #{@messages.last.inspect}"
      messagesCollectionView.reloadData
      goToBottomCollectionView
    })
  end

  def setupElements
    tf_new_message.delegate = self
  end

  def setupKeyboardNotifications
    tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:"hideKeyboard")
    tapGesture.delegate = self
    self.view.addGestureRecognizer(tapGesture)
  end

  #MARK - ACTIONS

  def sendMessage
    unless tf_new_message.text == ""
      @socket.emit('new message', args: [tf_new_message.text])
      @messages << Message.new(@username, tf_new_message.text)
      messagesCollectionView.reloadData
      tf_new_message.text = ""
      hideKeyboard
      goToBottomCollectionView
    end
  end

  def sendLocation
    @socket.emit('new message map', args: [{ :latitude => @location.coordinate.latitude, :longitude => @location.coordinate.longitude}])
    @messages << Message.new(@username,"", @location.coordinate.latitude, @location.coordinate.longitude)
    messagesCollectionView.reloadData
    goToBottomCollectionView
  end

  def goToBottomCollectionView
    p "goToBottomCollectionView"
    item = @messages.count - 1
    p "ITEM #{item}"
    if (item >= 0)
      index_path = NSIndexPath.indexPathForRow(item, inSection:0)
      p "INDEXPATH #{index_path}"
      messagesCollectionView.scrollToItemAtIndexPath(index_path, atScrollPosition: UICollectionViewScrollPositionBottom, animated: true)
    end
    p "endgoToBottomCollectionView"
  end

  def showActionSheet
    p "action"
    myActionSheet = UIActionSheet.alloc.init
    myActionSheet.addButtonWithTitle("Share Location")
    myActionSheet.addButtonWithTitle("Choose Image")
    myActionSheet.addButtonWithTitle("Cancel")
    myActionSheet.cancelButtonIndex = 2
    myActionSheet.showInView(self.view)
    myActionSheet.delegate = self
  end

  def hideKeyboard
    tf_new_message.resignFirstResponder
  end

  #MARK: - Notification Handler

  def keyboardDidShow(notification)
    info = notification.userInfo
    keyboardFrame = info[UIKeyboardFrameEndUserInfoKey].CGRectValue
    UIView.animateWithDuration(0.1, animations: lambda{
      bottomConstraint.constant = keyboardFrame.size.height
      #goToBottomCollectionView
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
    p "ENTRO PENElegado"
    messagesCollectionView.collectionViewLayout.invalidateLayout
    unless  @messages[indexPath.row].content == ""
      cell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageContentView", forIndexPath:indexPath)
      cell.setMessage(@messages[indexPath.row])
    else
      p "ENTRO PENE #{indexPath.row}"
      cell = collectionView.dequeueReusableCellWithReuseIdentifier("MapContentView", forIndexPath:indexPath)
      p "ENTROfgfgfggfgsgsd"
      cell.setMap(@messages[indexPath.row])
    end
    cell
  end

  def collectionView(collectionView, layout: collectionViewLayout,sizeForItemAtIndexPath: indexPath)
    unless  @messages[indexPath.row].content == ""
      height = MessageViewCell.heightForCellWithMessage(messages[indexPath.row].content)
    else
      height = 180
    end
    collectionView.collectionViewLayout.invalidateLayout
    CGSizeMake(UIScreen.mainScreen.bounds.size.width, height)
  end

  #MARK - TextField Delegates
  def textFieldDidBeginEditing textField
    @socket.emit('typing')
  end

  def textFieldEndEditing textField
    @socket.emit('stop typing')
  end

  #MARK - ActionSheet Delegates

  def actionSheet(myActionSheet, clickedButtonAtIndex: buttonIndex)
        if buttonIndex == 0
            #SVProgressHUD.showWithStatus("", maskType: 3)
            sendLocation
        end
  end

end