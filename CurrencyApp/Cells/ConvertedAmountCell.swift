//
//  ConvertedAmountCell.swift
//  CurrencyApp
//
//  Created by YK Poh on 14/06/2022.
//

import UIKit

class ConvertedAmountCell: UITableViewCell {
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var convertedAmountLabel: UILabel!
    
    let viewModel = ConvertedAmountViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        viewModel.convertedAmount.bind { [weak self] amount in
            guard let strongSelf = self else { return }
            strongSelf.convertedAmountLabel.text = amount
        }
        
        viewModel.exchangeRate.bind { [weak self] rate in
            guard let strongSelf = self else { return }
            strongSelf.exchangeRateLabel.text = rate
        }
    }

    func configure(_ viewModel: ConvertedAmountViewModel) {
        self.viewModel.convertedAmount.value = viewModel.convertedAmount.value
        self.viewModel.exchangeRate.value = viewModel.exchangeRate.value
    }
    
}
