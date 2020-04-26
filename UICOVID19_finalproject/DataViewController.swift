import UIKit
import CoreData
import Foundation

class DataViewController: UIViewController{
    
    let headers = [
        "x-rapidapi-host": "covid-19-statistics.p.rapidapi.com",
        "x-rapidapi-key": "3a43991df0mshbe7306c836e529ep1528e5jsn3aab283719f4"
    ]
    
    var ISO_codes: [String] = []
    var locations: [NSManagedObject] = []
    var locationIndex : Int?
    var location : NSManagedObject?
    
    var country: String = ""
    var stateprovince: String = ""
    var city: String = ""
    var date: Date = Date()
    var finishedUpdating: Bool = false
    var early_request_string: String = ""
    var cityFlag = false
    var regionFlag = false
    
    var confirmedCases: Int = 0
    var confirmedDeaths: Int = 0
    

    @IBOutlet weak var CasesLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var DeathsLabel: UILabel!
    @IBOutlet weak var DatePickerField: UIDatePicker!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    //DETERMINES WHICH FIELDS WERE POPULATED AND CREATES REQUEST STRING
    //BASED ON THEM
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        country = location!.value(forKeyPath: "country") as! String
        stateprovince = location!.value(forKeyPath: "stateprovince") as! String
        city = location!.value(forKeyPath: "city") as! String
        if( city == "" && stateprovince == "" ){
            LocationLabel.text = "\(country)"
            early_request_string = "https://covid-19-statistics.p.rapidapi.com/reports?iso=\(country)"
        }
        else if( city == "" ){
            LocationLabel.text = "\(stateprovince),  \(country)"
            early_request_string = "https://covid-19-statistics.p.rapidapi.com/reports?region_province=\(stateprovince)&iso=\(country)"
            regionFlag = true
        }
        else{
            LocationLabel.text = "\(city),  \(stateprovince),  \(country)"
            early_request_string = "https://covid-19-statistics.p.rapidapi.com/reports?region_province=\(stateprovince)&iso=\(country)&city_name=\(city)"
            cityFlag = true
        }
        updateDate(self)
    }
    
    //BOILERPLATE COREDATA STUFF
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        do {
            locations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //UPDATES THE DATA WHEN THE UPDATE DATE BUTTON IS PUSHED
    @IBAction func updateDate(_ sender: Any) {
        confirmedCases = 0
        confirmedDeaths = 0
        ErrorLabel.text = ""
        finishedUpdating = false
        date = DatePickerField.date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        var request_string = early_request_string + "&date=\(dateString)"
        request_string = request_string.replacingOccurrences(of: " ", with: "%20")
        let request = NSMutableURLRequest(url: NSURL(string: request_string)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil || data == nil {
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                return
            }
            guard let mime = response.mimeType, mime == "application/json" else {
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else{
                    return
                }
                guard let jsonData = json["data"] as? [Dictionary<String, Any>] else{
                    return
                }
                if( jsonData.isEmpty ){
                    self.errorHandler()
                    return
                }
                guard let jsonData2 = jsonData[0] as? [String:Any] else{
                    return
                }
                print(jsonData2)
                var covidData: [String:Any]
                if( self.cityFlag ){
                    guard let regionData = jsonData2["region"] as? [String:Any] else{
                        return
                    }
                    print(regionData)
                    guard let cityData = regionData["cities"] as? [Dictionary<String, Any>] else{
                        return
                    }
                    print(cityData)
                    self.confirmedCases = cityData[0]["confirmed"] as! Int
                    self.confirmedDeaths = cityData[0]["deaths"] as! Int
                }
                else if( self.regionFlag ){
                    self.confirmedCases = jsonData2["confirmed"] as! Int
                    self.confirmedDeaths = jsonData2["deaths"] as! Int
                }
                else{
                    for dict in jsonData{
                        self.confirmedCases += dict["confirmed"] as! Int
                        self.confirmedDeaths += dict["deaths"] as! Int
                    }
                    
                }
            }
            catch {
                print("JSON error: \(error.localizedDescription)")
                return
            }
            self.finishedUpdating = true
        }
        task.resume()
        while( !finishedUpdating ){
            continue
        }
        updateNumbers()
    }
    
    //HELPER FUNCTION FOR updateDate()
    func updateNumbers() {
        CasesLabel.text = String(confirmedCases)
        DeathsLabel.text = String(confirmedDeaths)
    }
    
    //HANDLES ERRORS
    func errorHandler(){
        finishedUpdating = true
        confirmedDeaths = 0
        confirmedCases = 0
        ErrorLabel.text = "Information Not Available. Pick a Different Date."
        updateNumbers()
    }
    
}
    
