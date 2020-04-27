//
//  PopUpViewController.swift
//  FinalProject
//
//  Created by Jia H Li on 4/26/20.
//  Copyright © 2020 Jiahong Li. All rights reserved.
//

import UIKit
import Stripe

protocol PopUpViewControllerDelegate {
    func didClickDone(_ token: STPToken)
}

class PopUpViewController: UIViewController {
    @IBOutlet weak var payClicked: UIButton!
    @IBOutlet weak var closeClicked: UIButton!
    
    let paymentCardTextField = STPPaymentCardTextField()
    
    var delegate: PopUpViewControllerDelegate?
    
    var price = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentCardTextField.delegate = self
        
        view.addSubview(paymentCardTextField)
        
        paymentCardTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([NSLayoutConstraint(item: paymentCardTextField, attribute: .top, relatedBy: .equal, toItem: closeClicked, attribute: .bottom, multiplier: 1, constant: 30)])
        view.addConstraints([NSLayoutConstraint(item: paymentCardTextField, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20)])
        view.addConstraints([NSLayoutConstraint(item: paymentCardTextField, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20)])
        view.layer.cornerRadius = 50
    }
    @IBAction func paymentClicked(_ sender: UIButton) {
        processCard()
        //finalizePayment(token: token)
    }
    @IBAction func closeClicked(_ sender: UIButton) {
        dismissView()
    }
    
//    func finalizePayment(token: STPToken) {
//        self.price = self.price * 100 //convert $ to cents
//
//        StripeClient.sharedClient.createAndConfirmPayment(token, amount: price) { (error) in
//            if error == nil {
//                print("payment successful")
//                //empty basket
//                //show notifcation
//            } else {
//                print("error", error!.localizedDescription)
//            }
//        }
//    }
    
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
//    private func showNotification(text: String, isError: Bool) {
//
//    }
    
    private func processCard(){
        let cardParams = STPCardParams()
        cardParams.number = paymentCardTextField.cardNumber
        cardParams.expMonth = paymentCardTextField.expirationMonth
        cardParams.expYear = paymentCardTextField.expirationYear
        cardParams.cvc = paymentCardTextField.cvc
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
            if error == nil {
                //print(token!)
                self.delegate?.didClickDone(token!)
                self.dismissView()
                
                self.price = self.price * 100 //convert $ to cents
                
                StripeClient.sharedClient.createAndConfirmPayment(token!, amount: self.price) { (error) in
                    if error == nil {
                        print("payment successful")
                        //empty basket
                        //show notifcation
                    } else {
                        print("error", error!.localizedDescription)
                    }
                }
            } else {
                print("error processing card token", error!.localizedDescription)
            }
        }
        
    }
}

extension PopUpViewController: STPPaymentCardTextFieldDelegate {
    
}
