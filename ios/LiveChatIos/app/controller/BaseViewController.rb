class BaseViewController < UIViewController
  extend IB

  attr_accessor :socket

  outlet :usernameTextField, UITextField
  outlet :goButton, UIButton

  def viewDidLoad
    super
    SIOSocket.socketWithHost("http://localhost:3000", response: lambda {  |socket|
      @socket = socket
      p "#{@socket.inspect}"
    })
    
    self.navigationController.navigationBar.translucent = false
  end


  def prepareForSegue segue, sender: sender
    @socket.emit("holi", args: ["hola"])
    p "envie"
    case segue.identifier
    when "MessageThreadDetailSegue"
      segue.destinationViewController.username = usernameTextField.text
    end
  end


end