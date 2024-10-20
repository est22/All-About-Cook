//
//  FoodICollectionViewController.swift
//  AllAboutCook
//
//  Created by Lia An on 9/9/24.
//

import UIKit

class FoodCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var ingredientData: [[String: Any]] = []
//    // received from previous VC
//    var index: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchWithFoodName("Apple") // initial default
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        searchWithFoodName(searchBar.text)
        

    }

    // MARK: - searchWithFoodName Method
    func searchWithFoodName(_ query: String?){
        guard let query else { return }

        let endPoint = "https://api.spoonacular.com/food/search?query=\(query)"
        
        
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
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let searchResults = json["searchResults"] as? [[String: Any]] {
                    // Extract results from the searchResults
                    var resultsArray: [[String: Any]] = []
                    
                    for result in searchResults {
                        if let results = result["results"] as? [[String: Any]] {
                            resultsArray.append(contentsOf: results)
//                            print(results) //
                            
                        }
                    }
                    /*
                    // Extract the desired properties from the resultsArray
                            for item in resultsArray {
                                if let link = item["link"] as? String,
                                   let name = item["name"] as? String,
                                   let image = item["image"] as? String {
                                    print("Link: \(link)")
                                    print("Name: \(name)")
                                    print("Image: \(image)")
                                } else {
                                    print("Error: Missing one or more fields in item: \(item)")
                                }
                            } */
                            
                    
                    
                    self.ingredientData = resultsArray
//                    print("ingredientData: \(self.ingredientData)")
                    // debug
//                    print("resultsArray:",resultsArray)
                    
                    
                    DispatchQueue.main.async {
                        
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error)")
            }
            
        }.resume()
        
        
        
    } // searchWithFoodName()
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "openWeb" {
            if segue.identifier == "openWeb" {
                        if let indexPath = sender as? IndexPath {
                            let detailVC = segue.destination as? WebViewController
                            let item = ingredientData[indexPath.item]
                            detailVC?.strURL = item["link"] as? String
                        }
                    }
            }
        
//        
//        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
//            let detailVC = segue.destination as? WebViewController
//            let item = ingredientData[indexPath.row]
//            
//            // Pass the link to the detail view controller
//            if let link = item["link"] as? String {
//                detailVC?.strURL = link
//            }
//        }
        
    }
    


}



extension FoodCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/2 - 2
        return CGSize(width: width, height: width*1.2)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}


extension FoodCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
    }
}


extension FoodCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ingredientData.count > 20 {
            return 20
        } else {return ingredientData.count}
   

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // Debugging print statement
//        print("ingredientData: \(ingredientData)")
        
        
        // Configure cell
        guard let imageView = cell.viewWithTag(1) as? UIImageView,
              let lblTitle = cell.viewWithTag(2) as? UILabel else {
            return cell
        }
        
        let item = ingredientData[indexPath.item]
        // Debugging print statement
//        print("Item at indexPath \(indexPath): \(item)")
        
   
        // Present cell
        lblTitle.text = item["name"] as? String
        if let imageUrl = item["image"] as? String, let url = URL(string: imageUrl) {
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data {
                            DispatchQueue.main.async {
                                imageView.image = UIImage(data: data)
                                
                            }
                            
                        
                        }
                        //self.collectionView.reloadData() // 추가
                    }
                    task.resume()
                } else {
                    // If image URL is not valid or missing, set a placeholder image or handle accordingly
                    imageView.image = UIImage(named: "Home")
                }

    
        return cell
    }

    
    
    // MARK: UICollectionViewDelegate
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openWeb", sender: indexPath)
//        print("indexPath.item: \(indexPath.item)")
        
    }
    
}
