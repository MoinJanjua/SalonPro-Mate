//
//  OrderViewController.swift
//  POS
//
//  Created by Maaz on 09/10/2024.
//

import UIKit

class OrderViewController: UIViewController, UITextFieldDelegate , UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var CustomerNameTF: DropDown!
    @IBOutlet weak var DressingTF: DropDown!
    @IBOutlet weak var ServicesTF: DropDown!
    @IBOutlet weak var GenderTF: DropDown!
    @IBOutlet weak var DateofOrder: UITextField!
    @IBOutlet weak var AmountTF: UITextField!
    @IBOutlet weak var DiscountTF: UITextField!
    @IBOutlet weak var AnyDescriptionTF: UITextField!
    @IBOutlet weak var NowAmountTF: UITextField!
    

    var pickedImage = UIImage()
    var Users_Detail: [User] = []
    
//    var products_Detail: [Products] = []
    var selectedOrderDetail: Ordered?
    var selectedIndex: Int?
    
    private var numberPicker = UIPickerView()
    private let numbers = Array(1...1000) // Array of numbers from 1 to 100
    private var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let userOrder = selectedOrderDetail {
            CustomerNameTF.text = userOrder.CustomerName
            DressingTF.text = userOrder.dressingtype
            ServicesTF.text = userOrder.servictypee
            GenderTF.text = userOrder.gender
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium // Adjust date style as needed
            dateFormatter.timeStyle = .none
            
            if let dateOfBirth = userOrder.date as? Date {
                DateofOrder.text = dateFormatter.string(from: dateOfBirth)
            } else if let dateOfBirthString = userOrder.date as? String {
                // If dateofbirth is already a String, just assign it
                DateofOrder.text = dateOfBirthString
            }
            AmountTF.text = userOrder.amount
            DiscountTF.text = userOrder.discount
            AnyDescriptionTF.text = userOrder.description

        }
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture2.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture2)
        
        setupDatePicker(for: DateofOrder, target: self, doneAction: #selector(donePressedDate))
        setupNumberPicker(for: DiscountTF)

        // GenderTF Dropdown
        GenderTF.optionArray = [ "Male","Female"]
        GenderTF.didSelect { (selectedText, index, id) in
            self.GenderTF.text = selectedText
        }
        GenderTF.delegate = self
        
        
        // PaymentTF Dropdown
        ServicesTF.optionArray = [ "Haircut",
                                   "Hair Coloring",
                                   "Blow Dry",
                                   "Keratin Treatment",
                                   "Manicure",
                                   "Pedicure",
                                   "Facial",
                                   "Waxing",
                                   "Threading",
                                   "Hair Spa",
                                   "Makeup Application",
                                   "Bridal Makeup",
                                   "Massage Therapy",
                                   "Hair Extensions",
                                   "Beard Grooming"]
        ServicesTF.didSelect { (selectedText, index, id) in
            self.ServicesTF.text = selectedText
        }
        ServicesTF.delegate = self
        
        // DressingTF Dropdown
        DressingTF.optionArray = [ "Buzz Cut",
                                   "Crew Cut",
                                   "Undercut",
                                   "Fade",
                                   "Pompadour",
                                   "Quiff",
                                   "Side Part",
                                   "Comb Over",
                                   "Textured Crop",
                                   "Slick Back",
                                   "Mohawk",
                                   "Mullet",
                                   "French Crop",
                                   "Caesar Cut",
                                   "Ivy League"]
        DressingTF.didSelect { (selectedText, index, id) in
            self.DressingTF.text = selectedText
        }
        DressingTF.delegate = self

        // Handle UserTF delegate if needed
        CustomerNameTF.delegate = self
        
        // Set delegates
          DiscountTF.delegate = self
          AmountTF.delegate = self
        


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load data from UserDefaults for Users_Detail
        if let savedData = UserDefaults.standard.array(forKey: "UserDetails") as? [Data] {
            let decoder = JSONDecoder()
            Users_Detail = savedData.compactMap { data in
                do {
                    let user = try decoder.decode(User.self, from: data)
                    return user
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        
        // Set up the dropdown options for UserTF
        setUpUserDropdown()
        
        
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func donePressedDate() {
        // Get the date from the picker and set it to the text field
        if let datePicker = DateofOrder.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            DateofOrder.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        DateofOrder.resignFirstResponder()
    }
  
    func applyDiscount() {
          guard let amountText = AmountTF.text,
                let originalAmount = Double(amountText),
                let discountText = DiscountTF.text,
                let discountValue = Double(discountText) else {
              // Handle invalid input
              showAlert(title: "Invalid Input", message: "Please enter valid numbers in Amount and Discount fields.")
              return
          }

          // Calculate the discounted amount
          let discount = (originalAmount * discountValue) / 100
          let discountedAmount = originalAmount - discount

          // Update the AmountTF with discounted value
          AmountTF.text = String(format: "%.2f", discountedAmount)

          // Optional: Visual feedback for successful discount application
          DiscountTF.backgroundColor = .systemGreen.withAlphaComponent(0.2)
          AmountTF.backgroundColor = .systemGreen.withAlphaComponent(0.2)

          // Reset background colors after a delay
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
           
          }
      }

      // Optional: Reset discounted amount when DiscountTF is cleared
      func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          if textField == DiscountTF, string.isEmpty {
              // Reset to original amount when discount field is cleared
              if let originalAmount = Double(AmountTF.text ?? "0") {
                  AmountTF.text = String(format: "%.2f", originalAmount)
              }
          }
          return true
      }
    func setupNumberPicker(for textField: UITextField) {
        // Set up the UIPickerView
        numberPicker.delegate = self
        numberPicker.dataSource = self
        
        // Assign the picker to the text field's input view
        textField.inputView = numberPicker
        
        // Add toolbar with "Done" button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolbar
        
        // Set text field delegate and track the active text field
        textField.delegate = self
    }
    @objc func donePressed() {
        // Get the selected number from the picker and set it to the active text field
        if let textField = activeTextField {
            let selectedRow = numberPicker.selectedRow(inComponent: 0)
            textField.text = "\(numbers[selectedRow])"
            textField.resignFirstResponder()
        }
    }
    
    // UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
     
    }
    // Reset background color for AmountTF and DiscountTF when DiscountTF is cleared
    func textField2(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == DiscountTF, string.isEmpty {
            // Reset AmountTF when DiscountTF is cleared
            if let originalAmount = Double(AmountTF.text ?? "0") {
                AmountTF.text = String(format: "%.2f", originalAmount)
            }
        }
        return true
    }
    // MARK: - UITextField Delegate
    
  
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        
        if textField == DiscountTF {
            applyDiscount()
        }
    }
    
    // MARK: - UIPickerView Data Source and Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(numbers[row])"
    }

    func makeImageViewCircular(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }

 

    // Set up User dropdown options from Users_Detail array
    func setUpUserDropdown() {
        // Check if Users_Detail array is empty
        if Users_Detail.isEmpty {
            // If no users are available, set the text field to "No user available"
            CustomerNameTF.text = "No Customer available please first add the Customer"
            CustomerNameTF.isUserInteractionEnabled = false // Disable interaction if no users are available
        } else {
            // Extract names from the Users_Detail array
            let userNames = Users_Detail.map { $0.Name }
            
            // Assign names to the dropdown
            CustomerNameTF.optionArray = userNames
            
            // Enable interaction if users are available
            CustomerNameTF.isUserInteractionEnabled = true
            
            // Handle selection from dropdown
            CustomerNameTF.didSelect { (selectedText, index, id) in
                self.CustomerNameTF.text = selectedText
                print("Selected user: \(self.Users_Detail[index])") // Optional: Handle selected user
            }
        }
    }
//    // Set up User dropdown options from Users_Detail array
//    func setUpProductsDropdown() {
//        // Check if Users_Detail array is empty
//        if products_Detail.isEmpty {
//            // If no users are available, set the text field to "No user available"
//            ProductTF.text = "No product available please first add the product"
//            ProductTF.isUserInteractionEnabled = false // Disable interaction if no users are available
//        } else {
//            // Extract names from the Users_Detail array
//            let userNames = products_Detail.map { $0.name }
//            
//            // Assign names to the dropdown
//            ProductTF.optionArray = userNames
//            
//            // Enable interaction if users are available
//            ProductTF.isUserInteractionEnabled = true
//            
//            // Handle selection from dropdown
//            ProductTF.didSelect { (selectedText, index, id) in
//                self.ProductTF.text = selectedText
//                print("Selected user: \(self.products_Detail[index])") // Optional: Handle selected user
//            }
//        }
//    }
    
    func clearTextFields() {
        CustomerNameTF.text = ""
        DressingTF.text = ""
        ServicesTF.text = ""
        DateofOrder.text = ""
        AmountTF.text = ""
        DiscountTF.text = ""
        AnyDescriptionTF.text = ""
        GenderTF.text = ""
    }
    func saveOrderData(_ sender: Any) {
        // Check if all mandatory fields are filled
        guard let customer = CustomerNameTF.text, !customer.isEmpty,
              let dressing = DressingTF.text, !dressing.isEmpty,
              let servicesType = ServicesTF.text, !servicesType.isEmpty,
              let Gender = GenderTF.text, !Gender.isEmpty,
              let DOO = DateofOrder.text, !DOO.isEmpty,
              let amount = AmountTF.text, !amount.isEmpty,
              let discounts = DiscountTF.text,
              let AnyDescription = AnyDescriptionTF.text

        else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        // Declare variables to hold payment details
//        var amounts: String? = nil
//        var discountss: String? = nil
//        var nowAmounts: String? = nil


        // Generate random character for order number
        let randomCharacter = generateOrderNumber()
        let CustomerId = generateCustomerId()

        // Create new order detail safely
        let newOrderDetail = Ordered(
            orderNo: "\(randomCharacter)", customerId: "\(CustomerId)",
            CustomerName: customer,
            dressingtype: dressing,
            gender: Gender,
            date: convertStringToDate(DOO) ?? Date(),
            servictypee: servicesType,
            amount: amount,
            discount: discounts,
            description:AnyDescription
//            nowAmount: Nowamounts ?? "N/A"

           
        )
        if let index = selectedIndex {
            updateSavedData(newOrderDetail, at: index) // Update existing entry
        } else {
            saveOrderDetail(newOrderDetail) // Save new entry
        }
        // Save the order detail
//        saveOrderDetail(newOrderDetail)
    }

    // Function to update existing data
    func updateSavedData(_ updatedTranslation: Ordered, at index: Int) {
        if var savedData = UserDefaults.standard.array(forKey: "OrderDetails") as? [Data] {
            let encoder = JSONEncoder()
            do {
                let updatedData = try encoder.encode(updatedTranslation)
                savedData[index] = updatedData // Update the specific index
                UserDefaults.standard.set(savedData, forKey: "OrderDetails")
            } catch {
                print("Error encoding data: \(error.localizedDescription)")
            }
        }
        showAlert(title: "Updated", message: "Your Order Has Been Updated Successfully.")
    }
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Corrected year format
        return dateFormatter.date(from: dateString)
    }
    
    func saveOrderDetail(_ order: Ordered) {
        var orders = UserDefaults.standard.object(forKey: "OrderDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(order)
            orders.append(data)
            UserDefaults.standard.set(orders, forKey: "OrderDetails")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Done", message: "Order Detail has been Saved successfully.")
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        saveOrderData(sender)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
