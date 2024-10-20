//
//  HomeSearchViewController.swift
//  AllAboutCook
//
//  Created by Lia An on 9/9/24.
//

import UIKit

class HomeSearchViewController: UIViewController {
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!

    
    var ingredientData: [[String:Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let ingredientUseVC = segue.destination as? IngredientUseTableViewController
        ingredientUseVC?.text = searchBar.text
        
        
    }
    

}



extension HomeSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = text
        performSegue(withIdentifier: "go", sender: nil)
        // 키보드가 알아서 내려가게끔
        searchBar.resignFirstResponder()
        
        
    }
}

