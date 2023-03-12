//
//  catagoryViewController.swift
//  Shopify App
//
//  Created by Ali Moustafa on 01/03/2023.
//

import UIKit
import Alamofire
import Floaty

class CatagoryViewController: UIViewController {
    var viewModel: CategoryViewModel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var laoding: UIActivityIndicatorView!
    @IBOutlet weak var subCategoriesCollectionViev: UICollectionView!{
        
        didSet{
            subCategoriesCollectionViev.register(UINib(nibName: "CatagoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CatagoryCollectionViewCell")
            subCategoriesCollectionViev.delegate = self
            subCategoriesCollectionViev.dataSource = self
        }
    }
    
    @IBOutlet weak var gridListButton: UIButton!
    @IBOutlet weak var productsCollectionView: UICollectionView!{
        didSet{
            
            productsCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
            
            productsCollectionView.register(UINib(nibName: "GridProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridProductCollectionViewCell")
            
            productsCollectionView.delegate = self
            productsCollectionView.dataSource = self
        }
    }
    let floaty = Floaty()
    var isFiltered = false
    var isList: Bool = true
    var isFavorite: Bool = false
    
    var isFiltering : Bool = false // for search bar
    var  searchedProducts  = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = searchBar
        viewModel = CategoryViewModel()
        viewModel.viewDidLoad()
        bindViewModelgategory()
        bindViewModelproduct()
        
        searchBar.delegate = self
        
        // Float Action button animation style
        makeFloatyStyleButton()
        DispatchQueue.main.async {
            self.laoding.hidesWhenStopped = true
            self.laoding.startAnimating()
        }
        //

    }
    
    private func bindViewModelgategory(){
        viewModel.didFetchData = {[weak self] in
            guard let self = self else {return}
            self.subCategoriesCollectionViev.reloadData()
        }
    }
    private func bindViewModelproduct(){
        viewModel.didFetchDatapro = {[weak self] in
            guard let self = self else {return}
            self.productsCollectionView.reloadData()
            self.laoding.stopAnimating()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)

    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
   
    
    @IBAction func didTapedGrid_ListButton(_ sender: UIButton) {
        
        isList.toggle()
        let imageList = UIImage(named: "list")
        let imageGrid = UIImage(named: "grid")
        let image = isList == true ? imageGrid : imageList
        gridListButton.setImage(image, for: .normal)
        productsCollectionView.reloadData()
    }
    
    
//floaty Button
    func makeFloatyStyleButton(){
        floaty.buttonColor =  .white
        floaty.paddingX = 10
        floaty.paddingY = 10
        floaty.openAnimationType = .slideLeft
        floaty.buttonImage = UIImage(named: "filter")
        floaty.itemButtonColor = .white
        floaty.itemTitleColor = .white
        floaty.addItem("ALL", icon: UIImage(named: "all")) { _ in
            self.isFiltered = false
            self.productsCollectionView.reloadData()
        }
        floaty.addItem("T-Shirts", icon: UIImage(named: "t-shirt")) { _ in
            let filered = self.viewModel.productOfbrandsCategoryModel?.products?.filter({ item in
                return item.product_type == "T-SHIRTS"
            })
            self.viewModel.FilterdArr = filered ?? []
            self.isFiltered = true
            self.productsCollectionView.reloadData()
        }
        floaty.addItem("Shoes", icon: UIImage(named: "shoes (2)")){ _ in
            let filered = self.viewModel.productOfbrandsCategoryModel?.products?.filter({ item in
                return item.product_type=="SHOES"
            })

            self.viewModel.FilterdArr = filered ?? []
            //print(self.viewModel.FilterdArr)
            self.isFiltered = true
            self.productsCollectionView.reloadData()
        }
        floaty.addItem("Accessories", icon: UIImage(named: "accessories")){ _ in
            let filered = self.viewModel.productOfbrandsCategoryModel?.products?.filter({ item in
                return item.product_type=="ACCESSORIES"
            })
            self.viewModel.FilterdArr = filered ?? []
            self.isFiltered = true
            self.productsCollectionView.reloadData()
        }
        view.addSubview(floaty)
    }
    //
}

extension CatagoryViewController : UISearchBarDelegate{

    var isSearchBarEmpty : Bool {
        return searchBar.text!.isEmpty
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if !searchText.isEmpty {
            isFiltering = true
        }
        print("from search func : \(isFiltering)")
        self.searchedProducts =  self.viewModel.productOfbrandsCategoryModel?.products?.filter({ product in
            return (product.title.lowercased().contains(searchText.lowercased()))
        }) ?? []
//
      self.subCategoriesCollectionViev.reloadData()
        if isSearchBarEmpty {
            isFiltering = false
            self.subCategoriesCollectionViev.reloadData()
        }
    }

}



extension CatagoryViewController: CollectionView_Delegate_DataSource_FlowLayout{
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == subCategoriesCollectionViev {
            return viewModel.subCategoriesNamesModel?.customCollections.count ?? 0
        }else if collectionView == productsCollectionView{
            
            
            if(isFiltered){
                return viewModel.FilterdArr?.count ?? 0
            }else{
                return viewModel.productOfbrandsCategoryModel?.products?.count ?? 0
            }
            
        }else{
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView{
        case subCategoriesCollectionViev:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatagoryCollectionViewCell", for: indexPath) as! CatagoryCollectionViewCell
            
            if let subcategory = viewModel.subCategoriesNamesModel?.customCollections[indexPath.row] {
                cell.categoryNameLabel.text = subcategory.title
            }
            return cell
        default:
            
            if isList == true{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as!ProductCollectionViewCell
            
                var productsArr = viewModel.productOfbrandsCategoryModel?.products
                var productKey = "\((productsArr?[indexPath.row].id)!)"
                
                if UserDefaults.standard.bool(forKey: productKey){
                    cell.favoritelist.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        //print("add Fav")
                      }else{
                          cell.favoritelist.setImage(UIImage(systemName: "heart"), for: .normal)
                           // print("not fav")
                    }
                    
             var favIsSelected =  UserDefaults.standard.bool(forKey: productKey)
             cell.favoritelist.isSelected =   UserDefaults.standard.bool(forKey: productKey)
             
         cell.addToWishList = { [unowned self] in
             
             cell.favoritelist.isSelected = !cell.favoritelist.isSelected

            if  cell.favoritelist.isSelected {

                cell.favoritelist.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                 // save to core data
                CoreDataManager.saveProductToCoreData(productName:productsArr?[indexPath.row].title ?? "" , productPrice: productsArr?[indexPath.row].variants?.first?.price ?? "", productImage: productsArr?[indexPath.row].image?.src ?? "", productId: productsArr?[indexPath.row].id ?? 0)
                     
                  UserDefaults.standard.set(true,
                                          forKey: "\(productsArr?[indexPath.row].id ?? 0)")

                 }else{
                     // delete from core data and change state
                     cell.favoritelist.setImage(UIImage(systemName: "heart"), for: .normal)
                     CoreDataManager.deleteFromCoreData(productName: productsArr?[indexPath.row].title ?? "" )
                     UserDefaults.standard.set(false,
                                               forKey: "\(productsArr?[indexPath.row].id ?? 0)")
                 }
         }
                
      print(isFiltering)
      if isFiltering {  // search filter
          print("Iam serach")
          cell.nameList.text = self.searchedProducts[indexPath.row].title
          cell.brandlist.text = self.searchedProducts[indexPath.row].product_type
            if let firstPrice = self.searchedProducts[indexPath.row].variants?.first?.price {
                cell.priceList.text = "$\(firstPrice)"
            } else {
                cell.priceList.text = ""
            }
            
            cell.imageList.kf.indicatorType = .activity
            
            if let imageUrl = URL(string: self.searchedProducts[indexPath.row].image?.src ?? "") {
                cell.imageList.kf.setImage(with: imageUrl)
                
            }
                    
        }
               
         if(isFiltered){
                    
            if let productOfbrandCategory = viewModel.FilterdArr?[indexPath.row] {
                        print("any thing")
                        cell.nameList.text = productOfbrandCategory.title
                        cell.brandlist.text = productOfbrandCategory.product_type
                        if let firstPrice = productOfbrandCategory.variants?.first?.price {
                            cell.priceList.text = "$\(firstPrice)"
                        } else {
                            cell.priceList.text = ""
                        }
                        
                        cell.imageList.kf.indicatorType = .activity
                        
                        if let imageUrl = URL(string: productOfbrandCategory.image?.src ?? "") {
                            cell.imageList.kf.setImage(with: imageUrl)
                            
                        }
                    }
                
            }else
                {
                if let productOfbrandCategory = viewModel.productOfbrandsCategoryModel?.products?[indexPath.row] {
                        cell.nameList.text = productOfbrandCategory.title
                        cell.brandlist.text = productOfbrandCategory.product_type
                    if let firstPrice = productOfbrandCategory.variants?.first?.price {
                            cell.priceList.text = "$\(firstPrice)"
                        } else {
                            cell.priceList.text = ""
                        }
                        
                        cell.imageList.kf.indicatorType = .activity
                        
                    if let imageUrl = URL(string: productOfbrandCategory.image?.src ?? "") {
                            cell.imageList.kf.setImage(with: imageUrl)
                            
                        }
                    }
                }
               
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridProductCollectionViewCell", for: indexPath) as!GridProductCollectionViewCell
             

                if(isFiltered){
                    
                    if let productOfbrandCategory = viewModel.FilterdArr?[indexPath.row] {
                        cell.nameGrid.text = productOfbrandCategory.title
                        cell.brandGrid.text = productOfbrandCategory.product_type
                        if let firstPrice = productOfbrandCategory.variants?.first?.price {
                            cell.priceGrid.text = "$\(firstPrice)"
                        } else {
                            cell.priceGrid.text = ""
                        }
                        
                        cell.imageGrid.kf.indicatorType = .activity
                        
                        if let imageUrl = URL(string: productOfbrandCategory.image?.src ?? "") {
                            cell.imageGrid.kf.setImage(with: imageUrl)
                            
                        }
                    }
            }else
                {
                if let productOfbrandCategory = viewModel.productOfbrandsCategoryModel?.products?[indexPath.row] {
                    cell.nameGrid.text = productOfbrandCategory.title
                    cell.brandGrid.text = productOfbrandCategory.product_type
                    if let firstPrice = productOfbrandCategory.variants?.first?.price {
                        cell.priceGrid.text = "$\(firstPrice)"
                    } else {
                        cell.priceGrid.text = ""
                    }
                    if let imageUrl = URL(string: productOfbrandCategory.image?.src ?? "") {
                        cell.imageGrid.kf.setImage(with: imageUrl)
                            
                        }
                    }
                }
               
                return cell
            }
        }
    }
}








extension CatagoryViewController {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView == subCategoriesCollectionViev {

            // Get the selected subcategory from the model
            guard let subcategory = viewModel.subCategoriesNamesModel?.customCollections[indexPath.item] else {
                return
            }
//            let productViewModel = CategoryViewModel()


            // Update the id variable with the collection ID of the selected subcategory
            viewModel.fetchProduct(id: String(subcategory.id))
//            viewModel. = "?collection_id=\(subcategory.id)"
//            print(subcategory.id)

        } else if collectionView == productsCollectionView {
            let product = viewModel.productOfbrandsCategoryModel?.products?[indexPath.row]
            let ProductVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductVC") as! ProductVC
            ProductVC.product = product
            self.navigationController?.pushViewController(ProductVC, animated: true)
        }

    }
    
    
}



//             Call the fetchProduct method again to fetch the updated data
//                        fetchproduct { result in
//                            DispatchQueue.main.async {
//                                self.productOfbrandsCategoryModel = result
//                                self.laoding.stopAnimating()
////                                 Reload the productsCollectionView to show products in the selected subcategory
//                                self.productsCollectionView.reloadData()
//                            }
//                        }
