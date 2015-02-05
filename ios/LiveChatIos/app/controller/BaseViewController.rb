class BaseViewController < UIViewController
  extend IB

  outlet :usernameTextView, UITextField
  outlet :goButton, UIButton
  outlet :lbl_name, UITextField

  def viewDidLoad
    super
    self.navigationController.navigationBar.translucent = false
  end


  #MARK - ACTIONS
  def get_username
  end

end