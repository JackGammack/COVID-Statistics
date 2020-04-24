import UIKit
import CoreData

// Global Array to store the CoreData object of each location
var locations: [NSManagedObject] = [];

// Custom TableViewCell for each Location
class LocationTableViewCell: UITableViewCell{
    @IBOutlet weak var CountryLabel: UILabel!
    @IBOutlet weak var StateProvinceLabel: UILabel!
    @IBOutlet weak var CityLabel: UILabel!
}

// Main ViewController for TableView
class LocationViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
      super.viewDidLoad()
      title = "Locations"
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // Checks for new locations every time the TableView is pulled up
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      let managedContext =
        appDelegate.persistentContainer.viewContext
      let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Location")
      do {
        locations = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
    
    
    // Reloads the data in the TableView every time it is pulled up
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    // Number of rows in table is length of locations array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return locations.count
    }
    
    // Each cell accesses a different CoreData Object that represents a location
    // Each location is accessed with adventurer=adventurers[indexPath.row]
    // Properties of the location are accessed by doing property=location.value(forKeyPath: "something")
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        let location: NSManagedObject = locations[indexPath.row]
        cell.CountryLabel?.text = location.value(forKeyPath: "country") as? String
        cell.StateProvinceLabel?.text = location.value(forKeyPath: "stateprovince") as? String
        cell.CityLabel?.text = location.value(forKeyPath: "city") as? String
        
      return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "datacontroller") {
            let vc = segue.destination as! DataViewController
            vc.locationIndex = tableView.indexPathForSelectedRow!.row
            vc.location = locations[vc.locationIndex!]
        }
    }
    
    // This is the code for deleting rows from the TableView
    // It deletes the row from the table and the data from the CoreData
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(locations[indexPath.row])
            do {
                try managedContext.save() // <- remember to put this :)
            }
            catch {
                fatalError()
            }
 
            locations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
}
