class MessageThreadController < UIViewController
  extend IB


  def viewDidLoad
    super
    self.navigationController.navigationBar.translucent = false
  end

end