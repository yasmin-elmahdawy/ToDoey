//
//  CategoryViewController.swift
//  Todoey
//
//  Created by G50 on 1/25/21.
//

import UIKit
import CoreData
import ChameleonFramework
import SwipeCellKit

//protocol DisplayCategoryData{
//    func displayCategoryData(category : Category)
//}

class CategoryVC : UITableViewController {

    //MARK:- Constants
    
    //Categories arr is an array of NSManagedObjects.
    var categoriesArr = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var alertTF = UITextField()
    //var delegate : DisplayCategoryData?
    
    //MARK:- ViewDidLoad method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        loadCategories()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
       //changing NavigationBar background Color.
        
        if let navBar = navigationController?.navigationBar {
           navBar.barTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //all cell set-up is made here by retreiving object values from CategoriesArr.
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as!CategoryCell
        
        cell.textLabel?.text = categoriesArr[indexPath.row].name
        
        if let color = UIColor(hexString: categoriesArr[indexPath.row].color!){
            cell.backgroundColor = color
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        }
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
    //MARK:- Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let toDoListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ToDoListVC") as! ToDoListVC
        
        //MARK:- USING DELEGATE
        let selectedCategory = categoriesArr[indexPath.row]
        toDoListVC.selectedCategory = selectedCategory
        //print(selectedCategory.name)
        //delegate?.displayCategoryData(category: selectedCategory)
         
        //accessing navigation Controller object that exists inside CategoryVC class.
        self.navigationController?.pushViewController(toDoListVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK:- SwipeTableViewCell to Delete.
    //Any changes on table such as Deleting an item requires first a permission.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Swipe to delete a Category from our CoreData.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        //Adding Delete Button as a contextual action(the handler here is what will be executed when this delete Btn is pressed).

        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in

            self.context.delete(self.categoriesArr[indexPath.row])
            self.categoriesArr.remove(at: indexPath.row)

            self.saveCategories()
        }

        delete.image = #imageLiteral(resourceName: "pin")
        delete.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        let swipe = UISwipeActionsConfiguration(actions: [delete])

        //For not deleting the item with long swipe only when clicking the delete Btn.
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }

    //MARK:- Data Manipulation Functions.
    func saveCategories(){
        
        do{
            //saving all operations in context into permanent storage container(Core data).
            try context.save()
        }catch{
            print("Error saving context \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    //making a fetch request.
    func loadCategories(){
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        //executing this fetch request using Context
        do{
           categoriesArr =  try context.fetch(request)
        }catch{
            print("error fetching data from context \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    //MARK:- Add new Category Btn Pressed.
    @IBAction func AddNewCategoryPressed(_ sender: UIBarButtonItem) {
        
        //Adding new AlertController
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "create a new category"
            textField.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.alertTF = textField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            if self.alertTF.text != ""{
        
                let newCategory = Category(context: self.context)
                newCategory.name = self.alertTF.text
                
                //When a new category is added,color property is integrated with it with a randomColor from chameleon frameWork.
                newCategory.color = UIColor.randomFlat().hexValue()
                
                self.categoriesArr.append(newCategory)
            }
            
            //the newCategory should be saved into our core data
            self.saveCategories()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }

    
}
 

