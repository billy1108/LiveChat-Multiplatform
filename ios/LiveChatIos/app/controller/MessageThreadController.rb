class MessageThreadController < UIViewController
  extend IB

  attr_accessor :username

  outlet :iv_user_profile, UIImageView
  outlet :tf_new_message, UITextField
  outlet :bottomConstraint, NSLayoutConstraint
  outlet :messagesCollectionView, UICollectionView


  def viewDidLoad
    super
    self.navigationController.navigationBar.translucent = false
  end



  #MARK - ACTIONS

  def send_message
    
  end



end