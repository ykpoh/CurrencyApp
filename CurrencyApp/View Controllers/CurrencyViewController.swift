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
    
    var isLoadingFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pickerView.delegate = self
        pickerView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        amountTextField.delegate = self
        
        title = "Convert"

        tableView.register(UINib(nibName: "\(ConvertedAmountCell.self)", bundle: nil), forCellReuseIdentifier: "\(ConvertedAmountCell.self)")
        
        currencyTextField.inputView = pickerView
        
        viewModel.amount.bind { [weak self] amount in
            guard let strongSelf = self else { return }

            UserDefaultService.save(key: .amount, value: amount)
            
            // Only set amount when loading the textfield for the first time
            if strongSelf.isLoadingFirstTime {
                strongSelf.amountTextField.text = String(amount)
                strongSelf.isLoadingFirstTime = !strongSelf.isLoadingFirstTime
            } else {
                strongSelf.viewModel.updateConvertedAmounts()
            }
        }
        
        viewModel.selectedCurrency.bind { [weak self] currency in
            guard let strongSelf = self else { return }
            
            if let currency = currency {
                UserDefaultService.encodeAndSave(key: .selectedCurrency, value: currency)
                strongSelf.viewModel.updateConvertedAmounts()
            }
            
            strongSelf.currencyTextField.text = currency?.fullName
            strongSelf.currencyTextField.resignFirstResponder()
        }
        
        viewModel.convertedAmounts.bind { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
        }
        
        viewModel.currencies.bind { [weak self] currencies in
            guard self != nil else { return }
            FileStorageService.save(value: currencies, fileType: .currencies)
        }
        
        viewModel.latestExchangeRateModel.bind { [weak self] value in
            guard self != nil else { return }
            FileStorageService.save(value: value, fileType: .latestExchangeRates)
        }
    }
}

extension CurrencyViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            viewModel.amount.value = Double(updatedText) ?? 0
        }
        return true
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
        if viewModel.selectedCurrency.value != selectedCurrency {
            viewModel.selectedCurrency.value = selectedCurrency
        }
    }
}

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.convertedAmounts.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !viewModel.convertedAmounts.value.isEmpty else {
            let cell = UITableViewCell()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ConvertedAmountCell.self)", for: indexPath) as! ConvertedAmountCell
        cell.configure(viewModel.convertedAmounts.value[indexPath.row])
        return cell
    }
}
