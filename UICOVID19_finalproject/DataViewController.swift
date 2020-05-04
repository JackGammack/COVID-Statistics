import UIKit
import CoreData
import Foundation

class DataViewController: UIViewController {
    
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
    
    var WeeklyDeaths: [Int] = []
    var WeeklyCases: [Int] = []
    var MonthlyCases: [Int] = []
    var MonthlyDeaths: [Int] = []
    var WeeklyPressed = false
    var MonthlyPressed = false
    let progress = Progress(totalUnitCount: 0)


    @IBOutlet weak var CasesLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var DeathsLabel: UILabel!
    @IBOutlet weak var DatePickerField: UIDatePicker!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var ProgressBar: UIProgressView!
    
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
                    self.finishedUpdating = true
                    self.confirmedDeaths = 0
                    self.confirmedCases = 0
                    self.ErrorLabel.text = "Information Not Available. Pick a Different Date."
                    self.CasesLabel.text = String(self.confirmedCases)
                    self.DeathsLabel.text = String(self.confirmedDeaths)
                    return
                }
                guard let jsonData2 = jsonData[0] as? [String:Any] else{
                    return
                }
                if( self.cityFlag ){
                    guard let regionData = jsonData2["region"] as? [String:Any] else{
                        return
                    }
                    guard let cityData = regionData["cities"] as? [Dictionary<String, Any>] else{
                        return
                    }
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
        WeeklyPressed = false
        MonthlyPressed = false
    }
    
    //HELPER FUNCTION FOR updateDate()
    func updateNumbers() {
        CasesLabel.text = String(confirmedCases)
        DeathsLabel.text = String(confirmedDeaths)
    }
    
    func updateProgress() {
        self.progress.completedUnitCount += 1
        print(self.progress.completedUnitCount)
        self.ProgressBar.setProgress(Float(self.progress.fractionCompleted), animated: true)
    }
    
    @IBAction func WeeklyGraphButton(_ sender: Any) {
//        let progress = Progress(totalUnitCount: 7)
//        self.ProgressBar.progress = 0.0;
//        progress.completedUnitCount = 0;
        if  WeeklyPressed == false {
            WeeklyPressed = true
            WeeklyDeaths.removeAll()
            WeeklyCases.removeAll()
            graphPointsDeaths.removeAll()
            graphPointsCases.removeAll()
            MonthlyPressed = false
            for i in 0...6 {
                //updateProgress()
                confirmedCases = 0
                confirmedDeaths = 0
                ErrorLabel.text = ""
                finishedUpdating = false
                date = DatePickerField.date - 604800 + (Double(i)*86400)
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
                            self.finishedUpdating = true
                            self.confirmedDeaths = 0
                            self.confirmedCases = 0
                            self.ErrorLabel.text = "Information Not Available. Pick a Different Date."
                            self.CasesLabel.text = String(self.confirmedCases)
                            self.DeathsLabel.text = String(self.confirmedDeaths)
                            return
                        }
                        guard let jsonData2 = jsonData[0] as? [String:Any] else{
                            return
                        }
                        if( self.cityFlag ){
                            guard let regionData = jsonData2["region"] as? [String:Any] else{
                                return
                            }
                            guard let cityData = regionData["cities"] as? [Dictionary<String, Any>] else{
                                return
                            }
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
                WeeklyDeaths.append(self.confirmedDeaths)
                WeeklyCases.append(self.confirmedCases)

            }
            graphPointsDeaths = WeeklyDeaths
            graphPointsCases = WeeklyCases
        }
        
    }
    
    
    @IBAction func MonthlyGraphData(_ sender: Any) {
//        let progress = Progress(totalUnitCount: 30)
//        self.ProgressBar.progress = 0.0;
//        progress.completedUnitCount = 0;
        if MonthlyPressed == false {
            MonthlyPressed = true
            MonthlyDeaths.removeAll()
            MonthlyCases.removeAll()
            graphPointsDeaths.removeAll()
            graphPointsCases.removeAll()
            WeeklyPressed = false
            for i in 0...29 {
                //updateProgress()
                confirmedCases = 0
                confirmedDeaths = 0
                ErrorLabel.text = ""
                finishedUpdating = false
                date = DatePickerField.date - 2592000 + (Double(i)*86400)
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
                            self.finishedUpdating = true
                            self.confirmedDeaths = 0
                            self.confirmedCases = 0
                            self.ErrorLabel.text = "Information Not Available. Pick a Different Date."
                            self.CasesLabel.text = String(self.confirmedCases)
                            self.DeathsLabel.text = String(self.confirmedDeaths)
                            return
                        }
                        guard let jsonData2 = jsonData[0] as? [String:Any] else{
                            return
                        }
                        if( self.cityFlag ){
                            guard let regionData = jsonData2["region"] as? [String:Any] else{
                                return
                            }
                            guard let cityData = regionData["cities"] as? [Dictionary<String, Any>] else{
                                return
                            }
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
                MonthlyDeaths.append(self.confirmedDeaths)
                MonthlyCases.append(self.confirmedCases)
                }
        }
        graphPointsDeaths = MonthlyDeaths
        graphPointsCases = MonthlyCases
    }
}
    
