import UIKit
import CoreData
import MapKit

// THIS IS THE VIEW CONTROLLER FOR THE ADD LOCATION VIEW
class AddLocationViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var CountryField: UITextField!
    @IBOutlet weak var StateProvinceField: UITextField!
    @IBOutlet weak var CityField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // ADDS LOCATION TO TABLE AND COREDATA WHEN THE SAVE BUTTON IS PRESSED
    // ONLY WORKS IF COUNTRY FIELD IS POPULATED
    @IBAction func addMember(_ sender: UIButton) {
        let _country = CountryField.text!
        let _stateprovince = StateProvinceField.text!
        let _city = CityField.text!
        
        if( _country != "" ){
            self.save(country: _country, stateprovince: _stateprovince, city: _city)
            CountryField.text = ""
            StateProvinceField.text = ""
            CityField.text = ""
        }
    }
    
    //NEED TO IMPLEMENT
    //COPY PASTED SOME STUFF FROM STACK OVERFLOW BUT HAVEN'T TESTED
    @IBAction func populateUsingLocation(_ sender: Any) {
        
        let locManager = CLLocationManager()
        locManager.delegate = self
        locManager.requestLocation()

        //let _longitude = currentLocation.coordinate.longitude
        //let _latitude = currentLocation.coordinate.latitude
        /*
        let location = CLLocation(latitude: _latitude, longitude: _longitude)
        location.fetchCityAndCountry { city, country, error in
            guard let city = city, let country = country, error == nil else {
                self.ErrorLabel.text = "There was an error finding location"
                return
            }
            self.ErrorLabel.text = ""
            self.CountryField.text = country
            self.CityField.text = city
        }
 */
    }
    
    // HELPER FUNCTION FOR addLocation()
    // CHANGES VALUES IN COREDATA USING location.setValue()
    // THIS FUNCTIONS ADDS THE NEW LOCATION TO THE locations ARRAY
    func save( country: String, stateprovince: String, city: String ) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let managedContext =
        appDelegate.persistentContainer.viewContext
      let entity = NSEntityDescription.entity(forEntityName: "Location",
                                   in: managedContext)!
      let location = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      location.setValue(country, forKeyPath: "country")
      location.setValue(stateprovince, forKeyPath: "stateprovince")
      location.setValue(city, forKeyPath: "city")
      do {
        try managedContext.save()
        locations.append(location)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
