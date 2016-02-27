/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/


import Foundation
import UIKit
import Bond
import DatePickerCell

class SettingsViewController: UITableViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var maxPickerCell: DatePickerCell!
  @IBOutlet weak var minPickerCell: DatePickerCell!
  @IBOutlet weak var creativeCommonsSwitch: UISwitch!
  @IBOutlet weak var filterDatesSwitch: UISwitch!
  
  // MARK: - Properties
  
  private let rowHeight: CGFloat = 44.0
  var viewModel: PhotoSearchMetadataViewModel?
  
  // MARK: - View life cycle
  
  override func viewDidLoad() {
    tableView.estimatedRowHeight = rowHeight
    
    maxPickerCell.leftLabel.text = "Max Date"
    minPickerCell.leftLabel.text = "Min Date"
    bindViewModel()
  }
  
  // MARK: - Actions
  
  @IBAction func doneButtonTapped(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil);
  }
  
  // MARK: - Helpers
  
  func bindViewModel() {
    guard let viewModel = viewModel else { return }
    
    viewModel.creativeCommons.bidirectionalBindTo(creativeCommonsSwitch.bnd_on)    
    viewModel.dateFilter.bidirectionalBindTo(filterDatesSwitch.bnd_on)
    
    let opacity: EventProducer<CGFloat> = viewModel.dateFilter.map { $0 ? 1.0 : 0.5 }
    opacity.bindTo(minPickerCell.leftLabel.bnd_alpha)
    opacity.bindTo(minPickerCell.rightLabel.bnd_alpha)
    opacity.bindTo(maxPickerCell.leftLabel.bnd_alpha)
    opacity.bindTo(maxPickerCell.rightLabel.bnd_alpha)
    
    bindModelDate(viewModel.minUploadDate, toPicker: minPickerCell)
    bindModelDate(viewModel.maxUploadDate, toPicker: maxPickerCell)
  }
  
  func bindModelDate(modelDate: Observable<NSDate>, toPicker picker: DatePickerCell) {
    modelDate.observe { picker.date = $0 }
    picker.datePicker.bnd_date.observe { modelDate.value = $0 }
  }
  
}
