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

import UIKit
import Async

class ViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var resultsTableView: UITableView!
  
  // MARK: - Properties
  
  private let viewModel = PhotoSearchViewModel()
  
  // MARK: - View life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    searchTextField.bnd_text.observe { print($0) }
    
//    searchTextField.bnd_text
//      .map { $0?.uppercaseString }
//      .observe { print($0) }
    
    searchTextField.bnd_text
      .map { $0?.characters.count < 4 }
      .bindTo(activityIndicator.bnd_hidden)
    
    bindViewModel()
  }
    
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard segue.identifier == "ShowSettings",
      let controller = (segue.destinationViewController as? UINavigationController)?.topViewController as? SettingsViewController
    else { return }
    
    controller.viewModel = viewModel.searchMetaDataViewModel
  }
  
  // MARK: - Helpers
  
  func bindViewModel() {
    viewModel.searchString.bidirectionalBindTo(searchTextField.bnd_text)
    
    viewModel.validSearchText
      .map { $0 ? UIColor.blackColor() : UIColor.redColor() }
      .bindTo(searchTextField.bnd_textColor)
    
    viewModel.searchResults.lift().bindTo(resultsTableView) { indexPath, dataSource, tableView -> UITableViewCell in
      let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! PhotoTableViewCell
      let photo = dataSource[indexPath.section][indexPath.row]
      cell.title.text = photo.title
      cell.photo.image = nil
      
      Async.background {
        guard let imageData = NSData(contentsOfURL: photo.url) else { return }
        
        Async.main {
          cell.photo.image = UIImage(data: imageData)
        }
      }
      
      return cell
    }
    
    viewModel.searchInProgress
      .map {!$0 }
      .bindTo(activityIndicator.bnd_hidden)
    
    viewModel.searchInProgress
      .map { $0 ? CGFloat(0.5) : CGFloat(1.0) }
      .bindTo(resultsTableView.bnd_alpha)
    
    viewModel.errorMessages.observe { [unowned self] error in
      let alertController = UIAlertController(title: "Oops!", message: error, preferredStyle: .Alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      self.presentViewController(alertController, animated: true, completion: nil)
    }
  }

}
