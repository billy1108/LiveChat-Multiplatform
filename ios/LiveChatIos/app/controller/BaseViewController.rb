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
      setupSocketListener
    })
    
    
    self.navigationController.navigationBar.translucent = false
  end

  def setupSocketListener
    @socket.on("new message", callback: lambda{ |data|
      msg = Message.new(data.first["username"], data.first["message"])
      p msg
    })
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