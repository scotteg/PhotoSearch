//
//  PhotoSearchViewModel.swift
//  BindingWithBond
//
//  Created by Scott Gardner on 2/27/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import Foundation
import Bond

class PhotoSearchViewModel {
  
  private let searchService: PhotoSearch = {
    let apiKey = NSBundle.mainBundle().objectForInfoDictionaryKey("apiKey") as! String
    return PhotoSearch(key: apiKey)
  }()
  
  let searchString = Observable<String?>("")
  let validSearchText = Observable<Bool>(false)
  let searchResults = ObservableArray<Photo>()
  let searchInProgress = Observable<Bool>(false)
  let errorMessages = EventProducer<String>()
  let searchMetaDataViewModel = PhotoSearchMetadataViewModel()
  
  init() {
    searchString.value = "Bond"
//    searchString.observeNew { print($0) }
    
    searchString
      .map { $0?.characters.count > 3 }
      .bindTo(validSearchText)
    
    searchString
      .filter { $0!.characters.count > 3 }
      .throttle(0.5, queue: Queue.Main)
      .observe { [unowned self] text in
        self.executeSearch(text!)
    }
    
    combineLatest(searchMetaDataViewModel.creativeCommons,
      searchMetaDataViewModel.dateFilter,
      searchMetaDataViewModel.maxUploadDate,
      searchMetaDataViewModel.minUploadDate)
      .throttle(0.5, queue: Queue.Main)
      .observe { [unowned self] _ in
        guard let searchString = self.searchString.value else { return }
        self.executeSearch(searchString)
    }
  }
  
  func executeSearch(text: String) {
    var query = PhotoQuery()
    query.text = searchString.value?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
    query.creativeCommonsLicence = searchMetaDataViewModel.creativeCommons.value
    query.dateFilter = searchMetaDataViewModel.dateFilter.value
    query.minDate = searchMetaDataViewModel.minUploadDate.value
    query.maxDate = searchMetaDataViewModel.maxUploadDate.value
    
    searchInProgress.value = true
    
    searchService.findPhotos(query) {
      self.searchInProgress.value = false
      
      switch $0 {
      case .Success(let photos):
        self.searchResults.removeAll()
        self.searchResults.insertContentsOf(photos, atIndex: 0)
      case .Error(let error):
        self.errorMessages.next("API error:\n\(error)")
      }
    }
  }
  
}