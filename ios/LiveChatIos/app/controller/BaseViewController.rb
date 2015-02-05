class BaseViewController < UIViewController
  extend IB

  attr_accessor :socket

  outlet :usernameTextField, UITextField
  outlet :goButton, UIButton

  def viewDidLoad
    super  
    self.navigationController.navigationBar.translucent = false
  end

  def prepareForSegue segue, sender: sender
    case segue.identifier
    when "MessageThreadDetailSegue"
      segue.destinationViewController.username = usernameTextField.text
      segue.destinationViewController.socket = @socket
    end
  end


end