//
//  ToDoListVC.swift
//  Todoey
//
//  Created by G50 on 1/16/21.
//

import UIKit
import CoreData
import ChameleonFramework

class ToDoListVC: UITableViewController {
    
  //MARK:- Constants
    var ToDoItems = [ToDoItem]()
    //let defaults = UserDefaults.standard
    
    //File Path to App's Documents Folder, where we created a new plist file to save our data.
    let userDataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItems.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //MARK:- IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var selectedCategory: Category?{
        didSet{
            loadItems()
        }
    }
    
    let categoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CategoryVC") as! CategoryVC
    
    override func  viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //optional binding for navigationController optional
        //else will be executed in case this navBar is equal to nil / doesn't exist
        guard let navBar = navigationController?.navigationBar else{fatalError("NavigationController doesn't exist")}
        
    
        if let hexString = selectedCategory?.color{
            
            //changing View Controller title into the selected category title
            title = selectedCategory!.name
    
            
            if let barTintColor = UIColor(hexString: hexString){
                
                //changing navigation Bar color based on the selected category color property.
                //put inside optional binding beacause barTintColor() returns an optional UIColor.
                navBar.barTintColor = UIColor(hexString: hexString)
                
                //contrasting tint colors of NavBar items with NavBar backgroundColor.
                navBar.tintColor = ContrastColorOf(barTintColor, returnFlat: true)
                
            }
        }
        
    }
    
    
  //MARK:- Helper Functions
    func setUpUI(){
        tableView.separatorStyle = .none
        
        //categoryVC.delegate = self
        //print(selectedCategory?.name)
        
        
        //retreiving array from userdefaults but first check if it exists using userdefaults.
         /* if let toDoArray = defaults.array(forKey: "toDoItemsArray") as? [ToDoItem]{
            ToDoItems = toDoArray
         }
         */
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ToDoItems.count
    }
    
    //this function asks the datasource for the cell that will be displayed at this specific location.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      //tableView local variable refers to a default name to the tableView IBOutlet.
         let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as! ToDoCell

        
        cell.textLabel?.text = ToDoItems[indexPath.row].title
        
        //Optional Binding for color(we don't know its existing or not).
        //darken(by:) method returns an optional UIColor but cell.background requires explicit UIColor.

        if let  category = selectedCategory{
            if let hexString = selectedCategory!.color{
            
            //checking value of this hex code of no nil value by Optional chaining.
            //if this hex code is not nil we will continue execution of darken method & if nil it will not be executed.
            if let color = UIColor(hexString: hexString)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(ToDoItems.count)){
                
                //giving cell gradient effect based on the indexPath.row of cell & number of items inside ToDoItems array.
                cell.backgroundColor = color
                
                //Contrasting Color property returns either a dark color or light color based on what contrasting algorithm seeing is better(Text color Contrasting inside cell).
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            }
          }
       }
        
        cell.accessoryType = ToDoItems[indexPath.row].done ? .checkmark : .none
         return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
    //MARK:- TABLE VIEW Delegate methods
    
    //1- this function detects which row/cell is selected , and execute some actions when clicked.
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let item = ToDoItems[indexPath.row]
        
        //changing done property from true to false and vice versa(UPDATE EXAMPLE we should commit those changes in context into Permanent Storage).
        item.done = !item.done
        
        saveItems()
        
       // to remove gray color that always appears when the cell is selected, to appears for seconds when the cell is clicked & then disappears.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK:- TableViewCell Swipe to delete
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //making swipe
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            
            self.context.delete(self.ToDoItems[indexPath.row])
            self.ToDoItems.remove(at: indexPath.row)
            
            self.saveItems()
          }
        delete.image = #imageLiteral(resourceName: "pin")
        delete.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        swipe.performsFirstActionWithFullSwipe = false
        
        return swipe
    }
    
    
    //MARK:- Add New Items
    @IBAction func addNewItemBtnPressed(_ sender: UIBarButtonItem) {
        
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
       
        alert.addTextField { (textField) in
            textField.placeholder = "create a new todo item"
            
            //because of textField var is a local, we can't access it from outside this closure.
            alertTextField = textField
        }
        
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
        
          //when this button is clicked,the item will be retreived from textfield after checking it's not empty and added to toDoItems array.
            if alertTextField.text != ""{
                
                let newItem = ToDoItem(context: self.context)
                
                newItem.title = alertTextField.text!
                //should pass a default value here because this property is not optional.
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
            
                self.ToDoItems.append(newItem)
                
                //Enconding ToDoItems array into plist file,using NSCoder.
                self.saveItems()
                
                //saving todo items array in user defaults,in plist file as key-value pairs.
                //self.defaults.set(self.ToDoItems, forKey: "toDoItemsArray")
                
            }
        }
         
        alert.addAction(addAction)
        
        //for showing this AlertController
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- DATA MODEL MANIPULATION FUNCTIONS.
    
    //MARK:- using NSCoder
     /* func saveItems(){
        
          let encoder = PropertyListEncoder()
        
            do{
            //encoding ToDoItems Array.
             let data = try encoder.encode(ToDoItems)
             
            //writing data to users document folder
            try data.write(to: userDataFilePath!)
                
          }catch{
             print("error encoding ToDoItems array \(error)")
         }
         tableView.reloadData()
      }*/

    /* func loadItemsFromPlist(){

        //getting data from documents folder, returning an optional as data may be not exist.
        if let data = try? Data(contentsOf: userDataFilePath!){

            //decoding data
            let decoder = PropertyListDecoder()
            do{
               ToDoItems = try decoder.decode([ToDoItem].self, from: data)
            }catch{
                print("Error Decoding Array \(error)")
            }
        }
         
        tableView.reloadData()
    } */
    
    //MARK:- Using  Core Data.
    func saveItems(){
        
        do{
            //saving all operations in context into permanent container(SQLite database)
            try context.save()
        }catch{
            print("Error Saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(),predicate : NSPredicate? = nil){
     
       //1- querying items associated with the selectedCategory(retreiving items whose category is equal to/matches the selected category).
       //2- the default predicate(search query) fetches only items with the selected category.
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        
        //unwrapping passed predicate ,for checking it hasn't null values.
        if let passedPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate , passedPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        //running our request and fetch results.
        do{
           ToDoItems = try context.fetch(request)
        }catch{
            print("Error fetching data from Context \(error.localizedDescription)")
        }
        
        //calling cellForRowAt(indexPath) method for updating our tableView with new data in ToDoItems arr retreived from SQLite DB.
        tableView.reloadData()
    }
    
}


 //MARK:- Search Bar delegate methods
extension ToDoListVC : UISearchBarDelegate{
    
    //When this Btn is clickeed we want to make query on data.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        //1- Modifying this request by making a query to retreive data based on specific criteria.
        //NSPredicate is a foundation class that specifies how data will be fetched or filtered.
        //2- Adding query to our request.
        let searchBarPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //1- sorting data returned at any order.
        //2- Adding SortDescriptor to our request.
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]//takes an array of sortDescriptors.
        
        loadItems(with: request, predicate: searchBarPredicate)
        
    }
    
    //MARK:- SearchBar textDidChange method
    
    //this method is called when the search bar text is changed or removing all text after this change(clicking cross button).
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
        //1- SearchBar text is empty after change, so keyboard will be dismissed & SearchBar Cursor should disappear.
        //2- in this case SearchBar is no longer the selected item in its window,it should return to the background thread to the state before its being activated.
        //this task of dismissing SearchBar is running on Main Thread while other Tasks in Background Thread being completed .
        
        if searchBar.text?.count == 0 {
          DispatchQueue.main.async {
            searchBar.resignFirstResponder()
         }
         
        //retreive data again from our SQLiteDatabase.
         loadItems()
     }
  }
}

//extension ToDoListVC : DisplayCategoryData{
//
//      func displayCategoryData(category: Category) {
//
//         selectedCategory = category
//      }
//}
