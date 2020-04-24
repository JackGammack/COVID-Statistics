import UIKit
import CoreData

class DataViewController: UIViewController{
    
    var locations: [NSManagedObject] = []
    var locationIndex : Int?
    var location : NSManagedObject?
    
    var country: String = ""
    var stateprovince: String = ""
    var city: String = ""
    var date: Date = Date()

    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var CasesLabel: UILabel!
    @IBOutlet weak var DeathsLabel: UILabel!
    @IBOutlet weak var DatePickerField: UIDatePicker!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        country = location!.value(forKeyPath: "country") as! String
        stateprovince = location!.value(forKeyPath: "stateprovince") as! String
        city = location!.value(forKeyPath: "city") as! String
        date = DatePickerField.date
        
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
    
}
    
