//
//  CurrencyViewController.swift
//  CurrencyApp
//
//  Created by YK Poh on 11/06/2022.
//

import UIKit

class CurrencyViewController: UIViewController {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = CurrencyViewModel()
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pickerView.delegate = self
        pickerView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        currencyTextField.inputView = pickerView
        
        viewModel.amount.bind { [weak self] amount in
            guard let strongSelf = self else { return }
            strongSelf.amountTextField.text = String(amount)
        }
        
        viewModel.selectedCurrency.bind { [weak self] currency in
            guard let strongSelf = self else { return }
            strongSelf.currencyTextField.text = currency?.fullName ?? "Select Currency"
            strongSelf.currencyTextField.resignFirstResponder()
        }
    }


}

extension CurrencyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.currencies.value.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.currencies.value[row].fullName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = viewModel.currencies.value[row]
        viewModel.selectedCurrency.value = selectedCurrency
        // Fetch converted amount
    }
    
}

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
