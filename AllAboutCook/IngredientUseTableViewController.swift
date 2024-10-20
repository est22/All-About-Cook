//
//  IngredientUseTableViewController.swift
//  AllAboutCook
//
//  Created by Lia An on 9/9/24.
//

import UIKit
let apiKey = "5e1e8d92f930498791f88852f9950778"

class IngredientUseTableViewController: UITableViewController {
    
    @IBOutlet weak var userInputLbl: UILabel!
    
    var ingredientData: [[String:Any]]?
    // received from previous VC
    var text: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        
        // Apply color to userInputLbl text
        textDesign(text)
        searchWithQuery(text)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
    }
    
    // MARK: - textDesign
    func textDesign(_ baseString: String?) {
        
        let baseString = "Let's make some fire with \n\(text?.lowercased() ?? "Please input any text") 😛"
        let attributedString = NSMutableAttributedString(string: baseString)
        // Define the range of the text to be colored
        let textRange: NSRange
        if let text = text?.lowercased() {
            let textWithSpace = "\(text) 😛" // Add space to match the string
            textRange = (baseString as NSString).range(of: textWithSpace)
        } else {
            textRange = (baseString as NSString).range(of: "Please input any text")
        }
        
        // Define the color you want to apply
        let color = UIColor.red // Change this to your desired color
        
        // Apply the color to the defined range
        attributedString.addAttribute(.foregroundColor, value: color, range: textRange)
        
        // Set the attributed text to the label
        userInputLbl.attributedText = attributedString
        
        
    }
    
    
    // MARK: - searchWithQuery Method
    func searchWithQuery(_ query: String?){
        guard let query else { return }
        
        // ingredients=apples,+flour,+sugar
        let transformedQuery = query.lowercased().components(separatedBy: ", ").joined(separator: ",+")
        
        let endPoint = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(transformedQuery)"
        
        guard let strURL = endPoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: endPoint) else { return }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        // session 연결
        let session = URLSession.shared
        
        // task 생성
        let task: Void = session.dataTask(with: request) { data, response, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let data else { return }
            // Fetch data
            do {
                guard let root = try JSONSerialization.jsonObject(with: data) as? [[String:Any]]
                else { return }
                
                
                self.ingredientData = root
                
//                // Test: "title" 값 출력
//                for item in root {
//                    if let title = item["title"] as? String {
//                        // Debug
//                        // print("Title: \(title)")
//                    }
//                } // end Test
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print("JSON Parsing Error Occured")
            }
            
        }.resume()
        
        
    }
    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientData?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let item = ingredientData?[indexPath.row] else { return cell }
        
        // tag 1: imageView
        let imageView = cell.viewWithTag(1) as? UIImageView
        
        // tag 2: title label
        let lblTitle = cell.viewWithTag(2) as? UILabel
        lblTitle?.text = item["title"] as? String

        
        // tag 3: used ingredients label
        let lblUsedIngredients = cell.viewWithTag(3) as? UILabel
        textDesign(lblUsedIngredients?.text)
        lblUsedIngredients?.text = "\(item["usedIngredientCount"] as? Int ?? 0)"
        
 
        
        // tag 4: missing ingredients label
        let lblMissedIngredients = cell.viewWithTag(4) as? UILabel
        textDesign(lblMissedIngredients?.text)
        lblMissedIngredients?.text = "\(item["missedIngredientCount"] as? Int ?? 0)"
        
        
        // image thumbnail
        if let thumbnail = item["image"] as? String { // guard-let 쓰면 return cell을 못하니까 전체가 다 안나옴.
            if let url = URL(string: thumbnail) {
                let request = URLRequest(url: url)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data {
                        DispatchQueue.main.async {
                            imageView?.image = UIImage(data: data)
                        }
                    }
                } // handler
                task.resume()
            }
        }
        
        
        return cell
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? DetailInstructionsTableViewController
        guard let indexPath = tableView.indexPathForSelectedRow,
              let item = ingredientData?[indexPath.row]
        else { return }
        
        // 다음 뷰로 넘길 프로퍼티
        detailVC?.queryId = item["id"] as? Int
        detailVC?.recipeTitle = item["title"] as? String
        detailVC?.menuImage = item["image"] as? String
        
        
        
        
        
    }
    
    
}
