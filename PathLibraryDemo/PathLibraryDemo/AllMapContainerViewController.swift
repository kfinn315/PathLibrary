//
//  AllMapContainerViewController.swift
//  PathLibraryDemo
//
//  Created by Kevin Finn on 3/29/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import PathPhoto
import Photos
import PathMap

class AllMapContainerViewController : UIViewController, AssetsPickerDelegate {
    var mapVC : MapViewController = MapViewController.instance
    
    @IBOutlet weak var container: UIView!
    
    var assetsPicker : AssetsPicker = AssetsPicker()
    var path : DemoPath?
    
    override func viewDidLoad() {
        assetsPicker.delegate = self
        
        path = DemoPath.random()
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(title: "Photos", style: .plain, target: self, action: #selector(displayPhotos)), animated: false)
        
        // Add Child View Controller
        addChildViewController(mapVC)
        
        // Add Child View as Subview
        view.addSubview(mapVC.view)
        
        // Configure Child View
        mapVC.view.frame = view.bounds
        mapVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        mapVC.didMove(toParentViewController: self)
    }
    @objc func displayPhotos(){
        let albumPicker = assetsPicker.getAlbumPicker()
        present(albumPicker, animated: true, completion: nil)
    }
    
    func onAlbumPicked(album: PHAssetCollection) {
        dismiss(animated: true, completion: nil)
        path?.albumId = album.localIdentifier
        mapVC.load(path: path!)
    }
    
    func onAssetsSelected(assets: [PHAsset]) {
        path?.albumId = assets.first?.localIdentifier
        mapVC.load(path: path!)

    }
    
}
