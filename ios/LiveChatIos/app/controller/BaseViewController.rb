class BaseViewController < UIViewController
  extend IB

  outlet :lbl_name, UITextField

  def viewDidLoad
    super
    self.navigationController.navigationBar.translucent = false
  end

  def setName
    
  end

end