import UIKit
import CoreData
import MapKit

// THIS IS THE VIEW CONTROLLER FOR THE ADD LOCATION VIEW
class AddLocationViewController: UIViewController, CLLocationManagerDelegate{
    
    let headers = [
        "x-rapidapi-host": "covid-19-statistics.p.rapidapi.com",
        "x-rapidapi-key": "3a43991df0mshbe7306c836e529ep1528e5jsn3aab283719f4"
    ]
    
    var statesDictionary = ["NM": "New Mexico", "SD": "South Dakota", "TN": "Tennessee", "VT": "Vermont", "WY": "Wyoming", "OR": "Oregon", "MI": "Michigan", "MS": "Mississippi", "WA": "Washington", "ID": "Idaho", "ND": "North Dakota", "GA": "Georgia", "UT": "Utah", "OH": "Ohio", "DE": "Delaware", "NC": "North Carolina", "NJ": "New Jersey", "IN": "Indiana", "IL": "Illinois", "HI": "Hawaii", "NH": "New Hampshire", "MO": "Missouri", "MD": "Maryland", "WV": "West Virginia", "MA": "Massachusetts", "IA": "Iowa", "KY": "Kentucky", "NE": "Nebraska", "SC": "South Carolina", "AZ": "Arizona", "KS": "Kansas", "NV": "Nevada", "WI": "Wisconsin", "RI": "Rhode Island", "FL": "Florida", "TX": "Texas", "AL": "Alabama", "CO": "Colorado", "AK": "Alaska", "VA": "Virginia", "AR": "Arkansas", "CA": "California", "LA": "Louisiana", "CT": "Connecticut", "NY": "New York", "MN": "Minnesota", "MT": "Montana", "OK": "Oklahoma", "PA": "Pennsylvania", "ME": "Maine"]
    
    @IBOutlet weak var CountryField: UITextField!
    @IBOutlet weak var StateProvinceField: UITextField!
    @IBOutlet weak var CityField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    var locManager = CLLocationManager()
    var location: CLLocation = CLLocation()
    var Accessible: Bool = true
    var ISO_codes: [String] = []
    var stateprovince_names: [String] = []
    var city_names: [String] = []
    
    var _country: String = ""
    var _stateprovince: String = ""
    var _city: String = ""
    var countryFinishedLoading: Bool = false
    var stateprovinceFinishedLoading: Bool = false
    var cityFinishedLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.delegate = self
    }
    
    // ADDS LOCATION TO TABLE AND COREDATA WHEN THE SAVE BUTTON IS PRESSED
    // ONLY WORKS IF COUNTRY FIELD IS POPULATED
    @IBAction func addMember(_ sender: UIButton) {
        countryFinishedLoading = false
        stateprovinceFinishedLoading = false
        cityFinishedLoading = false
        _country = CountryField.text!
        _stateprovince = StateProvinceField.text!
        _city = CityField.text!
        get_ISO_codes()
        while( !countryFinishedLoading ){
            continue
        }
        if( !ISO_codes.contains(_country) ){
            ErrorLabel.text = "Country Code Not Valid"
            return
        }
        if( _stateprovince != "" ){
            get_stateprovince_names()
            while( !stateprovinceFinishedLoading ){
                continue
            }
            if( !stateprovince_names.contains(_stateprovince) ){
                ErrorLabel.text = "Region Name Not Valid"
                return
            }
        }
        if( _city != "" ){
            get_city_names()
            while( !cityFinishedLoading ){
                continue
            }
            if( !city_names.contains(_city) || _country != "USA" ){
                ErrorLabel.text = "City Name Not Valid"
                return
            }
        }
        save(country: _country, stateprovince: _stateprovince, city: _city)
        CountryField.text = ""
        StateProvinceField.text = ""
        CityField.text = ""
        ErrorLabel.text = "Location Saved"
    }
    
    //IT WORKS BUT THE FORMATTING DOESN'T MATCH WELL WITH WHAT IS REQUIRED
    //NEED TO FIX
    //CALLS locationManager() FUNCTIONS
    @IBAction func populateUsingLocation(_ sender: Any) {
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locManager.requestWhenInUseAuthorization()
        }
        
        locManager.requestLocation()
        
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
        ErrorLabel.text = ""
    }
    
    // IF THE LOCATION IS FOUND, POPULATES THE TEXT FIELDS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _location = locations.first {
            print("Found user's location: \(_location)")
            location = _location
            location.fetchCityAndCountryAndStateprovince { city, country, stateprovince, error in
                guard var city = city, var country = country, var stateprovince = stateprovince, error == nil else {
                    self.ErrorLabel.text = "There was an error finding location"
                    return
                }
                print(city,stateprovince,country)
                if( country == "US" ){
                    country = "USA"
                    if( stateprovince != "" && self.statesDictionary[stateprovince] != nil ){
                        stateprovince = self.statesDictionary[stateprovince]!
                    }
                }
                else{
                    city = ""
                }
                if( city == "New York" ){
                    city = "New York City"
                }
                self.ErrorLabel.text = ""
                self.CountryField.text = country
                self.CityField.text = city
                self.StateProvinceField.text = stateprovince
                city = ""
                country = ""
                stateprovince = ""
            }
        }
    }

    //IF THERE'S AN ERROR FINDING LOCATION
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        ErrorLabel.text = "There was an error finding location"
    }
    
    //GETS LIST OF ISO CODES
    func get_ISO_codes( ){
        let request_string = "https://covid-19-statistics.p.rapidapi.com/regions"
        let request = NSMutableURLRequest(url: NSURL(string: request_string)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        ISO_codes = []

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil || data == nil {
                self.Accessible = false
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                self.Accessible = false
                return
            }
            guard let mime = response.mimeType, mime == "application/json" else {
                self.Accessible = false
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else{
                    self.Accessible = false
                    return
                }
                guard let jsonData = json["data"] as? [Dictionary<String, String>] else{
                    self.Accessible = false
                    return
                }
                for dct in jsonData{
                    self.ISO_codes.append(dct["iso"]!)
                }
            }
            catch {
                print("JSON error: \(error.localizedDescription)")
                return
            }
            self.countryFinishedLoading = true
        }
        task.resume()
    }
    
    //GETS LIST OF STATEPROVINCE NAMES FOR THE CHOSEN COUNTRY
    func get_stateprovince_names( ){
        stateprovince_names = []
        let request_string = "https://covid-19-statistics.p.rapidapi.com/provinces?iso=\(_country)"
        let request = NSMutableURLRequest(url: NSURL(string: request_string)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil || data == nil {
                self.Accessible = false
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                self.Accessible = false
                return
            }
            guard let mime = response.mimeType, mime == "application/json" else {
                self.Accessible = false
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else{
                    self.Accessible = false
                    return
                }
                guard let jsonData = json["data"] as? [Dictionary<String, Any>] else{
                    self.Accessible = false
                    return
                }
                for dct in jsonData{
                    self.stateprovince_names.append(dct["province"] as! String)
                }
            }
            catch {
                print("JSON error: \(error.localizedDescription)")
                return
            }
            self.stateprovinceFinishedLoading = true
        }
        task.resume()
    }
    
    //GETS LIST OF CITY NAMES FOR THE STATEPROVINCE
    func get_city_names( ){
        city_names = []
        var request_string = "https://covid-19-statistics.p.rapidapi.com/reports?region_province=\(_stateprovince)&iso=\(_country)"
        request_string = request_string.replacingOccurrences(of: " ", with: "%20")
        let request = NSMutableURLRequest(url: NSURL(string: request_string)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil || data == nil {
                self.Accessible = false
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                self.Accessible = false
                return
            }
            guard let mime = response.mimeType, mime == "application/json" else {
                self.Accessible = false
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else{
                    self.Accessible = false
                    return
                }
                guard let jsonData = json["data"] as? [Dictionary<String, Any>] else{
                    self.Accessible = false
                    return
                }
                guard let jsonData2 = jsonData[0] as? [String:Any] else{
                    self.Accessible = false
                    return
                }
                guard let regionData = jsonData2["region"] as? [String:Any] else{
                    self.Accessible = false
                    return
                }
                guard let cityData = regionData["cities"] as? [Dictionary<String, Any>] else{
                    self.Accessible = false
                    return
                }
                for dct in cityData{
                    self.city_names.append(dct["name"] as! String)
                }
            }
            catch {
                print("JSON error: \(error.localizedDescription)")
                return
            }
            self.cityFinishedLoading = true
        }
        task.resume()
    }
}

//HELPS POPULATE LOCATION
extension CLLocation {
    func fetchCityAndCountryAndStateprovince(completion: @escaping (_ city: String?, _ country:  String?, _ stateprovince: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.isoCountryCode, $0?.first?.administrativeArea, $1) }
    }
}
