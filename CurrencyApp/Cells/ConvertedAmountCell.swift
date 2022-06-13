//
//  ConvertedAmountCell.swift
//  CurrencyApp
//
//  Created by YK Poh on 12/06/2022.
//

import UIKit

class ConvertedAmountCell: UITableViewCell {
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var convertedAmountLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    func configMovieCell(movie: Movie) {
//        self.textLabel?.text = movie.title
//        self.detailTextLabel?.text = movie.releaseDate
//    }

}
