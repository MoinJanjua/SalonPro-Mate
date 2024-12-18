//
//  DetailViewController.swift
//  AssetAssign
//
//  Created by Moin Janjua on 19/08/2024.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var FullNameTF: UITextField!
    @IBOutlet weak var PhoneNoTF: UITextField!
    @IBOutlet weak var DateofBirthTF: UITextField!
    @IBOutlet weak var GenderTF: DropDown!
    @IBOutlet weak var AddressTF: UITextField!
    @IBOutlet weak var DescriptionTF: UITextField!
    
    @IBOutlet weak var Save_btn: UIButton!
    
    private var datePicker: UIDatePicker?
    var pickedImage = UIImage()
       
    override func viewDidLoad() {
        super.viewDidLoad()
                
    
        // Gender Dropdown
           GenderTF.optionArray = ["Male", "Female"]
           GenderTF.didSelect { (selectedText, index, id) in
               self.GenderTF.text = selectedText
           }
           GenderTF.delegate = self
        
        setupDatePicker(for: DateofBirthTF, target: self, doneAction: #selector(donePressed))
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture2.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture2)
    }
    @objc func hideKeyboard()
      {
          view.endEditing(true)
      }
    @objc func donePressed() {
           // Get the date from the picker and set it to the text field
           if let datePicker = DateofBirthTF.inputView as? UIDatePicker {
               let dateFormatter = DateFormatter()
               dateFormatter.dateStyle = .medium
               dateFormatter.timeStyle = .none
               DateofBirthTF.text = dateFormatter.string(from: datePicker.date)
           }
           // Dismiss the keyboard
        DateofBirthTF.resignFirstResponder()
       }
  
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    // Contact validation function
    func isValidContact(_ contact: String) -> Bool {
        let contactRegEx = "^\\d{11}$" // Regex to ensure exactly 11 digits
        let contactPred = NSPredicate(format: "SELF MATCHES %@", contactRegEx)
        return contactPred.evaluate(with: contact)
    }
    func makeImageViewCircular(imageView: UIImageView) {
           // Ensure the UIImageView is square
           imageView.layer.cornerRadius = imageView.frame.size.width / 2
           imageView.clipsToBounds = true
       }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func clearTextFields() {
        FullNameTF.text = ""
        DescriptionTF.text = ""
        GenderTF.text = ""
        DateofBirthTF.text = ""
        PhoneNoTF.text = ""
        AddressTF.text = ""
        
    }

    func saveData(_ sender: Any) {
        // Check if any of the text fields are empty
        guard let name = FullNameTF.text, !name.isEmpty,
              let Contact = PhoneNoTF.text, !Contact.isEmpty,
              let address = AddressTF.text,
              let Gender = GenderTF.text, !Gender.isEmpty,
              let DoB = DateofBirthTF.text,
              let Description = DescriptionTF.text

        else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
     
        let randomCharacter = generateRandomCharacter()
        let newDetail = User(
            id: "\(randomCharacter)",
            Name: name,
            contact: Contact,
            address: address,
            gender: Gender,
            dob:DoB,
            other: Description
           
            
            
        )
        saveUserDetail(newDetail)
    }
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust according to your string date format
        return dateFormatter.date(from: dateString)
    }
    
    func saveUserDetail(_ employee: User) {
        var employees = UserDefaults.standard.object(forKey: "UserDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(employee)
            employees.append(data)
            UserDefaults.standard.set(employees, forKey: "UserDetails")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Done", message: "Detail has been Saved successfully.")
    }
    
    
    @IBAction func SaveButton(_ sender: Any) {
        saveData(sender)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
