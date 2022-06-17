//
//  MockExtensions.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 17/06/2022.
//

import UIKit

extension ConvertedAmountCellTests {
    
    class MockCellDataSource: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }

}
