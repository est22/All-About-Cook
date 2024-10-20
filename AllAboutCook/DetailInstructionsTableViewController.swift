//
//  DetailInstructionsTableViewController.swift
//  AllAboutCook
//
//  Created by Lia An on 9/10/24.
//

import UIKit

class DetailInstructionsTableViewController: UITableViewController {
    
    // properties from prev. VC
    var queryId: Int?
    var recipeTitle: String?
    var menuImage: String?
    var ingredientData: [[String: Any]]?
    
    // storyboard
    @IBOutlet weak var recipeTitleLbl: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        getRecipeInstructions(queryId)
        
        // present properties from prev. View
        recipeTitleLbl.text = recipeTitle
        // image
        if let thumbnail = menuImage {
            if let url = URL(string: thumbnail) {
                let request = URLRequest(url: url)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data {
                        DispatchQueue.main.async {
                            self.menuImageView?.image = UIImage(data: data)
                        }
                    }
                } // handler
                task.resume()
            }
        }

    }
    
    
    // MARK: - getRecipeInstructions()
    func getRecipeInstructions(_ id: Int?){
        
        guard let id else { return }
        
        let endPoint = "https://api.spoonacular.com/recipes/\(id)/analyzedInstructions"
        
        
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
        return ingredientData?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of steps in the recipe for the given section
                guard let recipe = ingredientData?[section] as? [String: Any],
                      let steps = recipe["steps"] as? [[String: Any]] else {
                    return 0
                }
                return steps.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")

        var content = cell?.defaultContentConfiguration()
        
        guard let recipe = ingredientData?[indexPath.section] as? [String: Any],
              let steps = recipe["steps"] as? [[String: Any]],
              let step = steps[indexPath.row] as? [String:Any] else {
            content?.text = "Error loading step"
            cell?.contentConfiguration = content
            return cell!
        }
        
        
        let stepNumber = step["number"] as? Int ?? indexPath.row + 1
        let stepText = step["step"] as? String ?? "No description available"
        content?.text = "\(stepNumber). \(stepText)"
        cell?.contentConfiguration = content
        
        
        
        
        
        
        return cell!
    }


}




