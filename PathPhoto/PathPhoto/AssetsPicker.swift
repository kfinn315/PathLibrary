//
//  AssetsPicker.swift
//  PathPhoto
//
//  Created by Kevin Finn on 3/29/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import Photos
import AssetsPickerViewController

public protocol AssetsPickerDelegate : AnyObject {
    func onAlbumPicked(album: PHAssetCollection)
    func onAssetsSelected(assets: [PHAsset])
}
public class MyAssetsPickerVC : AssetsPickerViewController {
    
    public override init(pickerConfig: AssetsPickerConfig?) {
        super.init(pickerConfig: pickerConfig)
    }
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        onViewDidAppear?()
    }
    
    public var onViewDidAppear : (()->())?
}
public class AssetsPicker : AssetsAlbumViewControllerDelegate, AssetsPickerViewControllerDelegate{
    public weak var delegate : AssetsPickerDelegate?
    
    public init() {
    }
    
    public func getAlbumPicker() -> UIViewController {
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.albumIsShowEmptyAlbum = false
        pickerConfig.albumIsShowHiddenAlbum = false
        
        let picker = MyAssetsPickerVC(pickerConfig: pickerConfig)
        picker.pickerDelegate = self
        
        let albumVC = AssetsAlbumViewController(pickerConfig: pickerConfig)
        albumVC.delegate = self
        let albumNavi = UINavigationController(rootViewController: albumVC)
        albumNavi.modalPresentationStyle = .overCurrentContext
        
        if #available(iOS 11.0, *) {
            albumNavi.navigationBar.prefersLargeTitles = true
        }
        
        picker.modalPresentationStyle = .overCurrentContext
        //present(picker, animated: false, completion: nil)
        picker.view.isHidden = true
        picker.onViewDidAppear = {
            picker.present(albumNavi, animated: true, completion: {
                picker.view.isHidden = false
            })
        }
        
        return picker
    }
    
    @objc public func getPhotoPicker(selectAssets: [PHAsset]) -> AssetsPickerViewController {
        let photoConfig = AssetsPickerConfig()
        photoConfig.albumIsShowEmptyAlbum = false
        photoConfig.albumIsShowHiddenAlbum = false
        photoConfig.assetsMinimumSelectionCount = 0
        photoConfig.selectedAssets = selectAssets
        
        let photoPicker = AssetsPickerViewController(pickerConfig: photoConfig)
        photoPicker.pickerDelegate = self
        //present(photoPicker, animated: true, completion: nil)
        
        return photoPicker
    }
    
    //MARK:- AssetsPickerViewControllerDelegate Implementation
    public func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        // showEmptyMessage()
    }
    public func assetsPickerDidCancel(controller: AssetsPickerViewController) {}
    public func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        
        delegate?.onAssetsSelected(assets: assets)
//
//        if let assetCollection = assetCollection {
//            PhotoAlbumHelper.removeAll(from: assetCollection) { error
//                in
//                guard error == nil else {
//                    log.error(error!.localizedDescription)
//                    return
//                }
//
//                PhotoAlbumHelper.save(assets: assets, to: assetCollection) { error in
//                    guard error == nil else {
//                        log.error(error!.localizedDescription)
//                        return
//                    }
//
//                    self.refreshAssetCollection()
//                    self.pageDelegate?.albumUpdated()
//                }
//            }
//        }
    }
    public func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    public func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {}
    
    public func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    public func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {}
    
    //MARK:= AssetsAlbumPickerViewControllerDelegate implementation
    public func assetsAlbumViewControllerCancelled(controller: AssetsAlbumViewController) {
    }
    
    public func assetsAlbumViewController(controller: AssetsAlbumViewController, selected album: PHAssetCollection) {
        delegate?.onAlbumPicked(album: album)
    }
}
