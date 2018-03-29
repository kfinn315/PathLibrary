//
//  PhotoManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/19/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

//protocol IPhotoManager : class {
//    var isAuthorized : Bool {get}
//    var photoCollections : [PhotoCollection] {get}
//    var authorizationStatus : PHAuthorizationStatus {get}
//    var currentStatusAndAlbum : Driver<(PHAuthorizationStatus,PHAssetCollection?)>? {get}
//    var cachingImageManager : PHCachingImageManager? {get}
//
//    func updateCurrentAlbum(collectionid : String)
//    func requestPermission()
//    func getImageCollection(_ localid: String?) -> PHAssetCollection?
//    func fetchAssets(in collection: PHAssetCollection, options: PHFetchOptions?) -> PHFetchResult<PHAsset>
//    func addToCurrent(_ assets: [PHAsset], completion: ((Bool, Error?) -> ())?)
//}
/**
 Manages the current path's photo album and Photo permission
 */
class PhotoManager {
    private static var _shared : PhotoManager?
    
    private var _cachingImageManager : PHCachingImageManager?    
    public var cachingImageManager : PHCachingImageManager? {
        if isAuthorized {
            if _cachingImageManager == nil {
                _cachingImageManager = PHCachingImageManager()
            }
            
            return _cachingImageManager
        } else {
            return nil
        }
    }
    
    public var currentStatusAndAlbum : Driver<(PHAuthorizationStatus,PHAssetCollection?)>?
    public var authorizationStatus = PHPhotoLibrary.authorizationStatus()
    public var isAuthorized : Bool {
        return authorizationStatus == .authorized
    }
    
    private var permissionStatus : Driver<PHAuthorizationStatus>?
    private var fetchOptions = PHFetchOptions()
    private var permissionStatusSubject : BehaviorSubject<PHAuthorizationStatus>
    private var disposeBag = DisposeBag()
    
    public static var shared : PhotoManager {
        if _shared == nil {
            _shared = PhotoManager()
        }
        
        return _shared!
    }
    
    private init(){
        permissionStatusSubject = BehaviorSubject<PHAuthorizationStatus>(value: PHPhotoLibrary.authorizationStatus())
        
        permissionStatus = self.permissionStatusSubject.asDriver(onErrorJustReturn: PHAuthorizationStatus.denied)
    }
    
    public func requestPermission(){
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({[weak self] (status) in
                if status != .notDetermined {
                    self?.permissionStatusSubject.onNext(status)
                }
            })
        }
    }
    public func getImageCollection(_ localid: String?) -> PHAssetCollection? {
        guard isAuthorized, localid != nil else{
            return nil
        }
        if let coll = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localid!], options: nil).firstObject {
            return coll
        }
        
        return nil        
    }
    
    public func fetchAssets(in collection: PHAssetCollection, options: PHFetchOptions?) ->
        PHFetchResult<PHAsset>{
            
            guard self.isAuthorized else{
                return PHFetchResult<PHAsset>()
            }
            
            return PHAsset.fetchAssets(in: collection, options: options)
    }
}

extension PHImageManager {
    func requestImageThumbnail(for phasset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable:Any]?) -> Void) {
        self.requestImage(for: phasset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: nil, resultHandler: resultHandler)
    }
}
