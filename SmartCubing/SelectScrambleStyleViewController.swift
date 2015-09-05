//
//  SelectScrambleStyleViewController.swift
//  SmartCubing
//
//  Created by Michael Lavina on 9/5/15.
//  Copyright (c) 2015 Swiftoid. All rights reserved.
//

import UIKit

protocol SelectScrambleTypeViewControllerDelegate {
    func controller(controller: SelectScrambleStyleViewController, selectedType: Int)
}

class SelectScrambleStyleViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    var delegate: SelectScrambleTypeViewControllerDelegate?
 
    
    var currentlySelectedScrambleType :Int = 1;
    let SCRAMBLE_TABLE : [String] = ["2x2", "3x3", "4x4", "5x5", "Pryaminx", "Megaminx"];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(currentlySelectedScrambleType, inComponent: 0, animated: false);
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        if let delegate = self.delegate {
            delegate.controller(self, selectedType: picker.selectedRowInComponent(0));
        }
    }

    @IBAction func btnDoneClicked(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SCRAMBLE_TABLE.count;
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {


    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String
    {
        return SCRAMBLE_TABLE[row];
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
