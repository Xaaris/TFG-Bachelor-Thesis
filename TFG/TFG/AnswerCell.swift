//
//  AnswerCell.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
/**
    Class that represents a cell filled with a picture and the answer text.
    It also incorporates the progressView to show the user when the question will lock.
 */
class AnswerCell: UITableViewCell {

    @IBOutlet weak var AnswerSelectImage: UIImageView!
    @IBOutlet weak var AnswerTextLabel: UILabel!
    @IBOutlet weak var progressView: CircleProgressView!

}
