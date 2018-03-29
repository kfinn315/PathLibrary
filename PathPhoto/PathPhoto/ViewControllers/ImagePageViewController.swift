 //
 //  PageViewController.swift
 //  BreadcrumbsSwift
 //
 //  Created by Kevin Finn on 2/1/18.
 //  Copyright © 2018 Kevin Finn. All rights reserved.
 //
 
 import UIKit
 import Photos
 import AssetsPickerViewController
 
 public protocol ImagePageDelegate : AnyObject {
    func pagerTapped()
    func pageTapped(_: ImageViewController)
    func albumPicked(id: String)
    func albumUpdated()
 }
 
 /** PageViewController that displays full screen images from fetchResult, a PHFetchResult<PHAsset> object, in ImageViewControllers
  */
 public class ImagePageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, AssetsPickerViewControllerDelegate, AssetsAlbumViewControllerDelegate, ImageViewDelegate {
    public static let storyboardID = "ImagePage"
    
    public weak var pageDelegate : ImagePageDelegate?
    private weak var photoManager : PhotoManager! = PhotoManager.shared
    
    /// the asset collection to display in the pages
    public var assetCollection : PHAssetCollection? {
        didSet{
            if(photoManager.isAuthorized){
                self.fetchResult = getFetchResultFrom(assetCollection)
            }
        }
    }
    
    private var fetchResult: PHFetchResult<PHAsset>? {
        didSet{
            updatePager()
        }
    }
    
    private func assetAt(_ index: Int) -> PHAsset?{
        if fetchResult != nil, index < fetchResult!.count, index >= 0 {
            return fetchResult?.object(at: index) ?? nil
        } else{
            return nil
        }
    }
    
    private(set) lazy var orderedViewControllers: [ImageViewController] = { [weak self] in
        // if let storyboard = self?.storyboard {
        var views : [ImageViewController] = []
        
        for var i in 0..<3 {
            var viewController = UIStoryboard.init(name: "Photo", bundle: Bundle(for: ImagePageViewController.self)).instantiateViewController(withIdentifier: "ImageView") as! ImageViewController
            
            viewController.assetIndex = i
            viewController.asset = assetAt(i)
            
            viewController.delegate = self
            if self != nil {
                viewController.view.frame = self!.view.frame
            }
            
            views.append(viewController)
        }
        
        return views
        }()
    
    public override func viewDidLoad() {
        self.title = ""
        
        view.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPagerTapped)))
        
        updatePager()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //change the color underneath pages
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = self.view.frame
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if photoManager?.authorizationStatus == .notDetermined {
            photoManager?.requestPermission()
        }
        orderedViewControllers.first?.photoHelper.assetSize = self.view.frame.size
    }
    
    @objc public func onPagerTapped(){
        pageDelegate?.pagerTapped()
        
        if(fetchResult?.count ?? 0 > 0){
            showPhotosPicker()
        } else{
            showAlbumPicker()
        }
    }
    
    public func imageTapped(viewController: ImageViewController) {
        pageDelegate?.pageTapped(viewController)
        
        showPhotosPicker()
    }
    
    private func getFetchResultFrom(_ assetcollection: PHAssetCollection?) -> PHFetchResult<PHAsset>?{
        var fetchResult : PHFetchResult<PHAsset>?
        
        if assetcollection == nil {
            fetchResult = nil
        } else {
            fetchResult = self.photoManager?.fetchAssets(in: assetcollection!, options: nil)
        }
        return fetchResult
    }
    
    private func updatePager(){
        guard let firstPage = self.orderedViewControllers.first else{ return }
        
        if let fetchResult = fetchResult {
            firstPage.photoHelper.startCaching(fetchResult)
        }
        
        DispatchQueue.main.async {
            //disable scrolling and paging controller if there is 1 or 0 images
            if self.fetchResult == nil || self.fetchResult?.count == 0 {
                self.dataSource = nil
                firstPage.setAsset(asset: nil, assetIndex: 0)
                firstPage.showEmptyMessage()
            } else {
                if self.fetchResult!.count == 1 {
                    self.dataSource = nil
                } else {
                    self.dataSource = self
                }
                firstPage.hideEmptyMessage()
                firstPage.setAsset(asset: self.fetchResult!.firstObject, assetIndex: 0)
            }
            
            self.setViewControllers([self.orderedViewControllers.first!], direction: .forward, animated: true, completion: nil)
        }
    }
    func refreshAssetCollection() {
        self.fetchResult = getFetchResultFrom(assetCollection)
    }
    
    //MARK:- UIPageViewControllerDataSource implementation
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentVC = viewController as! ImageViewController
        guard let viewControllerIndex = orderedViewControllers.index(of: currentVC) else {
            return nil
        }
        
        let prevAssetIndex = (currentVC.assetIndex ?? 0) - 1
        var prevIndex = viewControllerIndex - 1
        if prevIndex < 0 {
            prevIndex = orderedViewControllers.count - 1
        }
        
        if let prevAsset =  assetAt(prevAssetIndex) {
            let prevVC = orderedViewControllers[prevIndex]
            log.info("load previous asset index \(prevAssetIndex)")
            prevVC.asset = prevAsset
            prevVC.assetIndex = prevAssetIndex
            return prevVC
        }
        
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentVC = viewController as! ImageViewController
        guard let viewControllerIndex = orderedViewControllers.index(of: currentVC) else {
            return nil
        }
        
        var nextIndex = viewControllerIndex + 1
        if nextIndex == orderedViewControllers.count {
            nextIndex = 0
        }
        let nextAssetIndex = (currentVC.assetIndex ?? 0) + 1
        
        if let nextAsset =  assetAt(nextAssetIndex) {
            let nextVC = orderedViewControllers[nextIndex]
            log.info("load nexgt asset index \(nextAssetIndex)")
            nextVC.asset = nextAsset
            nextVC.assetIndex = nextAssetIndex
            return nextVC
        }
        
        return nil
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return fetchResult?.count ?? 0
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pageViewController.viewControllers?.first?.view.tag ?? 0
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed { return }
        
        DispatchQueue.main.async() {
            pageViewController.dataSource = nil
            pageViewController.dataSource = self
        }
    }
    
    //MARK:- AssetsPicker
    
    private func showAlbumPicker() {
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.albumIsShowEmptyAlbum = false
        pickerConfig.albumIsShowHiddenAlbum = false
        
        let picker = AssetsPickerViewController(pickerConfig: pickerConfig)
        picker.pickerDelegate = self
        
        let albumVC = AssetsAlbumViewController(pickerConfig: pickerConfig)
        albumVC.delegate = self
        let albumNavi = UINavigationController(rootViewController: albumVC)
        albumNavi.modalPresentationStyle = .overCurrentContext
        
        if #available(iOS 11.0, *) {
            albumNavi.navigationBar.prefersLargeTitles = true
        }
        
        picker.modalPresentationStyle = .overCurrentContext
        present(picker, animated: false, completion: nil)
        picker.view.isHidden = true
        picker.present(albumNavi, animated: true, completion: {
            picker.view.isHidden = false
        })
    }
    
    @objc private func showPhotosPicker(){
        let photoConfig = AssetsPickerConfig()
        photoConfig.albumIsShowEmptyAlbum = false
        photoConfig.albumIsShowHiddenAlbum = false
        photoConfig.assetsMinimumSelectionCount = 0
        photoConfig.selectedAssets = []
        fetchResult?.enumerateObjects({ (asset, count, finish) in
            photoConfig.selectedAssets!.append(asset)
        })
        
        let photoPicker = AssetsPickerViewController(pickerConfig: photoConfig)
        photoPicker.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(erasePhotos)), animated: true)
        photoPicker.pickerDelegate = self
        present(photoPicker, animated: true, completion: nil)
    }
    @objc func erasePhotos() {
        
    }
    
    //MARK:- AssetsPickerViewControllerDelegate Implementation
    public func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        // showEmptyMessage()
    }
    public func assetsPickerDidCancel(controller: AssetsPickerViewController) {}
    public func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        if let assetCollection = assetCollection {
            PhotoAlbumHelper.removeAll(from: assetCollection) { error
                in
                guard error == nil else {
                    log.error(error!.localizedDescription)
                    return
                }
                
                PhotoAlbumHelper.save(assets: assets, to: assetCollection) { error in
                    guard error == nil else {
                        log.error(error!.localizedDescription)
                        return
                    }
                    
                    self.refreshAssetCollection()
                    self.pageDelegate?.albumUpdated()
                }
            }
        }
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
        assetCollection = album
        pageDelegate?.albumPicked(id: album.localIdentifier)
        dismiss(animated: true, completion: nil)
    }
    //    override func updateItemSize() {
    //        let viewWidth = view.bounds.size.width
    //
    //        let desiredItemWidth: CGFloat = 100
    //        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
    //        let padding: CGFloat = 15
    //        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
    //        let itemSize = CGSize(width: itemWidth, height: itemWidth)
    //
    //        collectionViewLayout.itemSize = itemSize
    //        collectionViewLayout.minimumInteritemSpacing = padding
    //        collectionViewLayout.minimumLineSpacing = padding
    //
    //        // Determine the size of the thumbnails to request from the PHCachingImageManager
    //        let scale = UIScreen.main.scale
    //        thumbnailSize = CGSize(width: itemSize.width * scale - imgPadding, height: itemSize.height * scale - imgPadding)
    //    }
    
 }
