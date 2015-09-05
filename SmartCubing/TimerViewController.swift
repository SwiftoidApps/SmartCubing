//
//  TimerViewController.swift
//  SmartCubing
//
//  Created by Michael Lavina on 9/5/15.
//  Copyright (c) 2015 Swiftoid. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController, UIPopoverPresentationControllerDelegate, SelectScrambleTypeViewControllerDelegate {
  
    
    @IBOutlet weak var selectScrambleType: UIBarButtonItem!
    
    var currentlySelectedScramble : Int = 1;
    let SCRAMBLE_TABLE : [String] = ["2x2", "3x3", "4x4", "5x5", "Pryaminx", "Megaminx"];

    override func viewDidLoad() {
        super.viewDidLoad()
        selectScrambleType.title = SCRAMBLE_TABLE[currentlySelectedScramble];
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    func controller(controller: SelectScrambleStyleViewController, selectedType : Int) {
        selectScrambleType.title = SCRAMBLE_TABLE[selectedType];
        currentlySelectedScramble = selectedType;
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectScrambleSegue" {
            let popoverViewController = segue.destinationViewController as SelectScrambleStyleViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.delegate = self;
            popoverViewController.currentlySelectedScrambleType = currentlySelectedScramble;

        }
    }


}
