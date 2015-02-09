class BaseViewController < UIViewController
  extend IB

  attr_accessor :socket

  outlet :usernameTextField, UITextField
  outlet :goButton, UIButton

  def viewDidLoad
    super
    self.navigationController.navigationBar.translucent = false
    setupKeyboardNotifications
  end

  def viewWillAppear(animated)
    locationManager
  end

  def locationManager
    p "locationmanager"
    @locationManager = CLLocationManager.alloc.init
    @locationManager.delegate = self
    if @locationManager.respondsToSelector("requestWhenInUseAuthorization")
      @locationManager.requestWhenInUseAuthorization
    end
    @locationManager.desiredAccuracy = KCLLocationAccuracyBest
    @locationManager.startUpdatingLocation
  end

  def setupKeyboardNotifications
    tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:"hideKeyboard")
    tapGesture.delegate = self
    self.view.addGestureRecognizer(tapGesture)
  end

  def prepareForSegue segue, sender: sender
    case segue.identifier
    when "MessageThreadDetailSegue"
      segue.destinationViewController.username = usernameTextField.text
      segue.destinationViewController.socket = @socket
      segue.destinationViewController.location = @location
    end
  end

  #MARK - ACTIONS

  def hideKeyboard
    usernameTextField.resignFirstResponder
  end

  def goToMessageThread
    SVProgressHUD.showWithStatus("", maskType: 2)
    p "DFfdsfdssd"
    self.performSegueWithIdentifier("MessageThreadDetailSegue", sender: nil)
  end

  #MARK - Location Delegates
  def locationManager(manager, didUpdateLocations:locations)
    p "didUpdateLocations"
    @location = locations.lastObject
    @locationManager.stopUpdatingLocation
    p "LOCATION #{@location}"
  end

  def locationManager(manager, didFailWithError:error)
    p "didFailWithError"
    # AlertMessage.information(self, "Yogabuddy couldn't get your location")
  end

  def locationManager(manager, didFinishDeferredUpdatesWithError:error)    
    p "didFinishDeferredUpdatesWithError"
    # AlertMessage.information(self, "#{error.description}")
  end

  def locationManager manager, didChangeAuthorizationStatus: status
    p "didChangeAuthorizationStatus"
    case status
      when KCLAuthorizationStatusNotDetermined
        # User hasn’t yet been asked to authorize location updates
      when KCLAuthorizationStatusRestricted
        # User has location services turned off in Settings (Parental Restrictions)
      when KCLAuthorizationStatusDenied
        # User has been asked for authorization and tapped “No” (or turned off location in Settings)
        AlertMessage.init(self, '"LiveChatIos" Would Like to Use Your Current Location', "Go to Settings > Privacy > Location Services and turn it on for LiveChatIos")
      when KCLAuthorizationStatusAuthorized
        # User has been asked for authorization and tapped “Yes” on iOS 7 and lower.
      when KCLAuthorizationStatusAuthorizedWhenInUse
        # User has authorized use only when the app is in the foreground.
    end
  end

end