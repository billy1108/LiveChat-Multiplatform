class MapViewCell < UICollectionViewCell
  extend IB

  outlet :usernameLabel, UILabel
  outlet :timeLabel, UILabel
  outlet :mapView, MKMapView

  def setMap(message)
    p "PENEEEEEEEE"
    @message = message
    p "peneeeeeeSSDFASDF #{message.latitude}"
    p "fdsasadspeneeeeeeSSDFASDF #{message.longitude}"
    setUsername
    setCurrentTime
    mapView.zoomEnabled = false
    mapView.scrollEnabled = false
    mapView.userInteractionEnabled = true
    @coordinate = CLLocationCoordinate2DMake(message.latitude, message.longitude)
    annotation = MKPointAnnotation.alloc.init
    annotation.setCoordinate(@coordinate)
    region = MKCoordinateRegion.new(@coordinate, MKCoordinateSpan.new(0.005, 0.005))
    mapView.addAnnotation(annotation)
    mapView.setRegion(region, animated:false)
    mapView.layer.borderWidth = 2
    mapView.layer.borderColor = UIColor.blueColor
  end

  def setUsername
    usernameLabel.text = @message.username
    usernameLabel.font = UIFont.fontWithName("Helvetica", size:13.0)
  end

  def setCurrentTime
    today = NSDate.date
    dateFormatter = NSDateFormatter.alloc.init
    dateFormatter.setTimeStyle(NSDateFormatterShortStyle)
    currentTime = dateFormatter.stringFromDate(today)
    timeLabel.text = currentTime
    timeLabel.font = UIFont.fontWithName("Helvetica", size:13.0)
  end
  
end