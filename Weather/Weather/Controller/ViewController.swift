//
//  ViewController.swift
//  Weather
//
//  Created by Nikhil on 09/04/23.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {
    
    @IBOutlet weak var locationName : UILabel!
    @IBOutlet weak var temprature : UILabel!
    @IBOutlet weak var climate : UILabel!
    @IBOutlet weak var temperatureMaxMin : UILabel!
    @IBOutlet weak var lblSunrise : UILabel!
    @IBOutlet weak var lblSunset : UILabel!
    @IBOutlet weak var lblHumidity : UILabel!
    @IBOutlet weak var lblFeelsLike : UILabel!
    @IBOutlet weak var lblPressure : UILabel!
    
    @IBOutlet weak var View1 : UIView!
    @IBOutlet weak var View2 : UIView!
    @IBOutlet weak var View3 : UIView!
    @IBOutlet weak var View4 : UIView!
    
    
    var lat = 00.00
    var lon = 00.00
    
    let key = "344a1504194f54a4c5ab2f412d4c5788"
    
    var locManager = CLLocationManager()
    var currentUserLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.requestLocation()
        
        
        setRoundCornerToView(View: View1)
        setRoundCornerToView(View: View2)
        setRoundCornerToView(View: View3)
        setRoundCornerToView(View: View4)
        
    }
    
    //MARK : API
    func getWeatherData(lat:  Double , lon: Double )
    {
        let key = "344a1504194f54a4c5ab2f412d4c5788"
        
        guard let url = URL(string:  "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(key)&units=metric")
                
        else{
            fatalError("Error")
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { [self]  data, response, error -> Void in
            do {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(Response.self, from: data!)
                DispatchQueue.main.async { [self] in
                    locationName.text = responseModel.name
                    temprature.text = "\(temperature(temp: responseModel.main.temp))°"
                    lblFeelsLike.text = "\(temperature(temp: responseModel.main.feels_like))°"
                    
                    temperatureMaxMin.text =
                    "H: \(temperature(temp: responseModel.main.temp_max))°     L: \(temperature(temp: responseModel.main.temp_min))°"
                    lblPressure.text = "\(responseModel.main.pressure) hPa"
                    lblHumidity.text = "\(responseModel.main.humidity)%"
                    
                    lblSunrise.text = "\(createDateTime(timestamp: String(responseModel.sys.sunrise)))"
                    lblSunset.text = "\(createDateTime(timestamp: String(responseModel.sys.sunset)))"
                    
                    for i in responseModel.weather{
                        climate.text = (i.description).uppercased()
                    }
                }
                
            } catch {
                print("JSON Serialization error")
            }
            
        }).resume()
    }
}

extension UIViewController{
    
    func temperature(temp: Double) -> String{
        return String(format: "%.1f", temp)
    }
    
    func createDateTime(timestamp: String) -> String {
        var strDate = "undefined"
        
        if let unixTime = Double(timestamp) {
            let date = Date(timeIntervalSince1970: unixTime)
            let dateFormatter = DateFormatter()
            let timezone = TimeZone.current.abbreviation() ?? ""
            dateFormatter.timeZone = TimeZone(abbreviation: timezone)
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "hh:mm a"
            strDate = dateFormatter.string(from: date)
        }
        return strDate
    }
    
    func setRoundCornerToView(View: UIView) {
        
        View.backgroundColor = UIColor.white
        View.layer.cornerRadius = 10.0
        View.layer.borderColor = UIColor.lightGray.cgColor
        View.layer.borderWidth = 0.5
        View.clipsToBounds = true
    }
}
extension ViewController : CLLocationManagerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
            
            getWeatherData(lat: lat, lon: lon)
            
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            
        }
    }
    
}
