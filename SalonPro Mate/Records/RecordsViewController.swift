//
//  RecordsViewController.swift
//  POS
//
//  Created by Maaz on 10/10/2024.
//

import UIKit

class RecordsViewController: UIViewController {
    
    @IBOutlet weak var seacrhBar: UISearchBar!
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!  // Add this outlet for the label

    var order_Detail: [Ordered] = []
    var filteredOrders: [Ordered] = [] // Array to store filtered results
      var isSearching: Bool = false // To track search state
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.dataSource = self
        TableView.delegate = self
        seacrhBar.delegate = self // Set search bar delegate

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load data from UserDefaults
        if let savedData = UserDefaults.standard.array(forKey: "OrderDetails") as? [Data] {
            let decoder = JSONDecoder()
            order_Detail = savedData.compactMap { data in
                do {
                    let order = try decoder.decode(Ordered.self, from: data)
                    return order
                } catch {
                    print("Error decoding order: \(error.localizedDescription)")
                    return nil
                }
            }
        }

        // Show or hide table view and label based on data availability
        noDataLabel.text = "There is no sales data available"
        if order_Detail.isEmpty {
            TableView.isHidden = true
            noDataLabel.isHidden = false
        } else {
            TableView.isHidden = false
            noDataLabel.isHidden = true
        }
        
        filteredOrders = order_Detail // Initially show all data
        TableView.reloadData()
    }
//    func generatePDF() {
//           let pdfFileName = NSTemporaryDirectory() + "SalesDetails.pdf"
//           
//           let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // Standard A4 size
//           
//           do {
//               try renderer.writePDF(to: URL(fileURLWithPath: pdfFileName)) { context in
//                   context.beginPage()
//                   
//                   // Title
//                   let title = "Order Details"
//                   let titleAttributes: [NSAttributedString.Key: Any] = [
//                       .font: UIFont.boldSystemFont(ofSize: 18)
//                   ]
//                   title.draw(at: CGPoint(x: 20, y: 20), withAttributes: titleAttributes)
//                   
//                   // Table header
//                   let header = "Product | Payment Type | Amount | User | Date"
//                   let headerAttributes: [NSAttributedString.Key: Any] = [
//                       .font: UIFont.boldSystemFont(ofSize: 14)
//                   ]
//                   header.draw(at: CGPoint(x: 20, y: 60), withAttributes: headerAttributes)
//                   
//                   // Draw data
//                   var currentY = 90
//                   for order in order_Detail {
//                       let orderLine = "\(order.product) | \(order.paymentType) | \(order.nowAmount) | \(order.user) | \(formatDate(order.DateOfOrder))"
//                       let lineAttributes: [NSAttributedString.Key: Any] = [
//                           .font: UIFont.systemFont(ofSize: 12)
//                       ]
//                       orderLine.draw(at: CGPoint(x: 20, y: CGFloat(currentY)), withAttributes: lineAttributes)
//                       currentY += 20
//                       
//                       if currentY > 750 { // Prevent content overflow
//                           context.beginPage()
//                           currentY = 20
//                       }
//                   }
//               }
//               
//               // Share or present the PDF
//               let pdfURL = URL(fileURLWithPath: pdfFileName)
//               let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
//               self.present(activityVC, animated: true, completion: nil)
//               
//           } catch {
//               print("Failed to create PDF: \(error.localizedDescription)")
//           }
//       }
//       
//       func formatDate(_ date: Date) -> String {
//           let formatter = DateFormatter()
//           formatter.dateFormat = "dd-MM-yyyy"
//           return formatter.string(from: date)
//       }
//    
//    private func clearUserData() {
//        // Remove keys related to user data but not login information
//        UserDefaults.standard.removeObject(forKey: "OrderDetails")
//        
//
// }
//
//    private func showResetConfirmation() {
//        let confirmationAlert = UIAlertController(title: "Reset Complete", message: "The data has been reset successfully.", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        confirmationAlert.addAction(okAction)
//        self.present(confirmationAlert, animated: true, completion: nil)
//    }
    @IBAction func ClearAllSalesButton(_ sender: Any) {
//        let alert = UIAlertController(title: "Remove Sales Data", message: "Are you sure you want to remove all the sales data?", preferredStyle: .alert)
//          
//          let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
//              // Step 1: Clear user-specific data from UserDefaults
//              self.clearUserData()
//              
//              // Step 2: Clear the data source (order_Detail array)
//              self.order_Detail.removeAll()
//              
//              // Step 3: Reload the table view to reflect the change
//              self.TableView.reloadData()
//              
//              // Step 4: Optionally, show a confirmation to the user
//              self.showResetConfirmation()
//          }
//          
//          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//          
//          alert.addAction(confirmAction)
//          alert.addAction(cancelAction)
//          
//          self.present(alert, animated: true, completion: nil)
    }
    @IBAction func pdfGeneratorButton(_ sender: Any) {
//     generatePDF()
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
extension RecordsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredOrders.count : order_Detail.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsCell", for: indexPath) as! RecordsTableViewCell

        let orderData = isSearching ? filteredOrders[indexPath.row] : order_Detail[indexPath.row]
        cell.customernameLabel?.text = orderData.CustomerName
        cell.dressingTypeLbl?.text = orderData.dressingtype
        cell.servicesLbl?.text = orderData.servictypee
        cell.AmountLbl?.text = "Amount: \(orderData.amount)"
        cell.discountLbl?.text = "Discount: \(orderData.discount)%"

        // Convert the Date object to a String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: orderData.date)
        cell.dateLbl.text = dateString
        
        if orderData.gender == "Male" {
            cell.ImageView.image = UIImage(named: "userb")
        } else if orderData.gender == "Female" {
            cell.ImageView.image = UIImage(named: "userg")
        } else {
            cell.ImageView.image = nil // Clear the image for unexpected cases
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            order_Detail.remove(at: indexPath.row)
            
            let encoder = JSONEncoder()
            do {
                let encodedData = try order_Detail.map { try encoder.encode($0) }
                UserDefaults.standard.set(encodedData, forKey: "OrderDetails")
            } catch {
                print("Error encoding medications: \(error.localizedDescription)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let orderData = order_Detail[indexPath.row]
     //   let id = emp_Detail[sender.tag].id
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "OrderViewController") as! OrderViewController
        newViewController.selectedOrderDetail = orderData
        newViewController.selectedIndex = indexPath.row // Pass the index for updating
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
        
        
    }
}

extension RecordsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredOrders = order_Detail
        } else {
            isSearching = true
            filteredOrders = order_Detail.filter { order in
                order.CustomerName.lowercased().contains(searchText.lowercased())
            }
        }
        
        TableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredOrders = order_Detail
        TableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
