//
//  FirstViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Main View")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadExampleDataButtonPressed(sender: AnyObject) {
        let csvURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Sample1", ofType: "csv")!)
//                print(csvURL)
        do{
            let text = try String(contentsOfURL: csvURL)
            let csv = CSwiftV(String: text, separator: ";")
            let rows = csv.rows
            let headers = csv.headers
            let keyedRows = csv.keyedRows!
//            print(headers)
//            print(rows)
            print("")
            print(keyedRows[1])
            print(keyedRows[2])
            print(keyedRows[3])
        }catch{
            print(error)
        }
        

    }

}

