//
//  OrderResultViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/4.
//

import UIKit

class OrderResultViewController: UIViewController {
    
    @IBOutlet weak var resultStatusLabel: UILabel!
    @IBOutlet weak var sideTagButton: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var createdAtTimeLabel: UILabel!
    @IBOutlet weak var doneAtTimeLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var fundsLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var detailsView: UIView!
    
    var orderDetails: Order?
    
    @IBAction func confirmDetails(_ sender: Any) {
        // Go to wallet page
        if let tabBarController = self.tabBarController {
            let desiredTabIndex = 1
            if desiredTabIndex < tabBarController.viewControllers?.count ?? 0 {
                tabBarController.selectedIndex = desiredTabIndex
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        CoinbaseService.shared.fetchProductOrders(productID: <#T##String#>, status: <#T##String#>, limit: <#T##Int#>) { <#[Order]#> in
//            <#code#>
//        }
        
        guard let orderDetails = orderDetails else {
            print("No Order Details Received.")
            return
        }
        updateDetails(order: orderDetails)
    }
    
    private func setupUI() {
        detailsView.layer.cornerRadius = 5
        sideTagButton.layer.cornerRadius = 5
        confirmButton.layer.cornerRadius = 5
    }
    
    func updateDetails(order: Order) {
        self.sideTagButton.titleLabel?.text = order.side
        self.sizeLabel.text = order.size
        self.createdAtTimeLabel.text = order.createdAt
        self.doneAtTimeLabel.text = order.doneAt
        self.priceLabel.text = order.price
        self.fundsLabel.text = order.funds
    }
}

extension OrderResultViewController: OrderDelegate {
    func didSendOrder(orderID: String) {
//        let order = CoinbaseService.shared.
        print("😛 I received Order ID: \(orderID)")
    }
}
