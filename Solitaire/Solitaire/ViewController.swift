//
//  ViewController.swift
//  Solitaire
//
//  Created by David Ciupei on 4/26/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var Solitaire: SolitaireView!
    
    lazy var solitaire : Solitaire! = { // reference to model in app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.solitaire
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func newGame(_ sender: Any) {
        solitaire.freshGame()
        self.Solitaire.layoutSublayers(of: Solitaire.layer)
    }

}

