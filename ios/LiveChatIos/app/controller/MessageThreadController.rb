class MessageThreadController < UIViewController
  extend IB

  attr_accessor :username

  def viewDidLoad
    super
    self.navigationController.navigationBar.translucent = false
    setup_elements
  end


  #MARK - ACTIONS

  def send_message
    
  end



end