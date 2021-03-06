import UIKit
import FirebaseFirestore
import Firebase
import SwiftUI
import Foundation

class EditTaskViewController: UIViewController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    deinit{
        
    }
    
    private var db = Firestore.firestore()
    let uid = Auth.auth().currentUser!.uid
    var urlLabel = ""
    var descLabel = ""
    var titleLabel = ""
    var docLabel = ""
    var photo = UIImageView()
    
//    var alertWindows = AlertWindows()

    // Fields for updating an entry
    @IBOutlet weak var titleUpdateTF: UITextField!
    @IBOutlet weak var urlUpdateTF: UITextField!
    @IBOutlet weak var descUpdateTF: UITextField!
   
    // Fields for deleting an entry
        
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        showDeleteTask(docLabel: docLabel)
        
    }
    
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        showUpdateTask(docLabel: docLabel)
        
//            db.collection("Tasks").document(docLabel).updateData([
//                "title": title,
//                "description": description,
//                "url": url,
//            ]) { err in
//                if let err = err {
//                    print("Error updating document: \(err)")
//                } else {
//                    print("Document successfully updated")
//                }
//            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleUpdateTF.text = titleLabel
        descUpdateTF.text = descLabel
        urlUpdateTF.text = urlLabel
        
        
        // Do any additional setup after loading the view.
    }
    
    func showUpdateTask(docLabel: String){
        let alert = UIAlertController(title: "Update Task", message: "Would you like to update task", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: {_ in
            //Place code here
            guard let title = self.titleUpdateTF.text, !title.isEmpty,
                  let description = self.descUpdateTF.text, !description.isEmpty,
                  let url = self.urlUpdateTF.text, !url.isEmpty else{
                      print("There is missing information")
                        return
                  }
            
            self.db.collection("Tasks").document(self.docLabel).getDocument { snapshot, err in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    guard let snap = snapshot else {return}
                    var trace = false
                    
                    let data = snap.data()
                    let uidd = data!["uid"] as? String ?? ""
                    if (self.uid == uidd){
                        trace = true
                        self.db.collection("Tasks").document(self.docLabel).updateData([
                            "title": title,
                            "description": description,
                            "url": url,
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                                
                            } else {
                                print("Document successfully updated")
                            }
                        }
                        
                        self.performSegue(withIdentifier: "deleteToMainSegue", sender: self)
                    }
                    if(trace == false){
                        self.couldNotDeleteTask()
                    }
                }
            }
            
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in}))
        present(alert, animated: true)
    }

    
    func showDeleteTask(docLabel: String){
        let alert = UIAlertController(title: "Delete Task", message: "Would you like to delete task", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {_ in
            //Place code here
            
            self.db.collection("Tasks").getDocuments { snapshot, err in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    guard let snap = snapshot else {return}
                    var trace = false
                    for document in snap.documents{
                        print("Inside docs")
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let uidd = data["uid"] as? String ?? ""
                        if (self.titleLabel == title && self.uid == uidd){
                            print("Found one")
                            document.reference.delete()
                            trace = true
                        }
                    }
                    if(trace == false){
                        self.couldNotDeleteTask()
                    }
                    self.performSegue(withIdentifier: "deleteToMainSegue", sender: self)
                }
            }
//            self.db.collection("Tasks").document(docLabel).delete{ err in
//                if let err = err {
//                  print("Error removing document: \(err)")
//                }
//                else {
//                  print("Document successfully removed!")
//                }
//            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in}))
        present(alert, animated: true)
    }
    func couldNotDeleteTask(){
        let alert = UIAlertController(title: "Error", message: "You can only delete/edit your own taks", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in}))
        present(alert, animated: true)
    }
    
}
