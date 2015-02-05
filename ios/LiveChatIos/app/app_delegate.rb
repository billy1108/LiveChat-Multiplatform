class AppDelegate

  attr_accessor :storyboard

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    launch
    true
  end

  def launch
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @storyboard = UIStoryboard.storyboardWithName("LiveChatIos", bundle:nil)
    @window.rootViewController = controller_with_identifier("Main")
    
    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible
  end

  def controller_with_identifier identifier
    @storyboard.instantiateViewControllerWithIdentifier(identifier)
  end

end

