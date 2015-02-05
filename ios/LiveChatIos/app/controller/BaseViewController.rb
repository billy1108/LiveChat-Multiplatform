class BaseViewController < UIViewController
  extend IB

  outlet :usernameTextField, UITextField
  outlet :goButton, UIButton

  def viewDidLoad
    super
    socketIO = SocketIO.alloc.initWithDelegate(self)
    p "#{socketIO.inspect}"
    self.navigationController.navigationBar.translucent = false
  end


  def prepareForSegue segue, sender: sender
    case segue.identifier
    when "MessageThreadDetailSegue"
      segue.destinationViewController.username = usernameTextField.text
    end
  end


end