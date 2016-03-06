//
//  QuizResultsTableViewCell.swift
//  TFG
//
//  Created by Johannes Berger on 06.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class QuizResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var xOutOfxLabel: UILabel!
    
    var delegate: QuizResultsCellDelegate?
    
    @IBAction func quitButtonPressed(sender: AnyObject) {
       delegate?.goBackToRootVC()
    }
}

protocol QuizResultsCellDelegate {
    func goBackToRootVC()
}
