//
//  MapViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import Photos
import RxSwift
import RxCocoa
import PathPhoto

/**
 ViewController that displays the current Path and photo collection in a MapView object
 */
public class MapViewController: UIViewController {
    public static let storyboardID = "MapVC"
    
    @IBOutlet weak var mapView: MapView!
    
    //    private weak var pathManager = PathManager.shared
    //    private weak var photosManager = PhotoManager.shared
    //
    var fetchResults : PHFetchResult<PHAsset>?
    {
        didSet{
            var annotations : [ImageAnnotation] = []
            fetchResults?.enumerateObjects({ (asset, index, pointer) in
                let annot = ImageAnnotation()
                annot.asset = asset
                annotations.append(annot)
            })
            mapView.setImageAnnotations(annotations)
        }
    }
    private var disposeBag = DisposeBag()
    let delegate : MapViewDelegate = MapViewDelegate()
    
    public static var instance : MapViewController = {
        return UIStoryboard.init(name: "MapStoryboard", bundle: Bundle(for: MapViewController.self)).instantiateViewController(withIdentifier: MapViewController.storyboardID) as! MapViewController
    }()
    public func load(path: IPathBase){
        DispatchQueue.main.async {
            log.debug("mapview current path driver - on next")
            self.mapView.load(coordinates: path.getPoints())
            if let albumId = path.albumId {
                self.fetchResults = PHAsset.fetchAssets(withLocalIdentifiers: [albumId], options: nil)
            } else{
                self.fetchResults = nil
            }
        }
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        log.debug("mapview did load")
        mapView.delegate = delegate
    }
    override public func viewWillAppear(_ animated: Bool) {
        log.debug("mapview will appear")
        //photosManager?.requestPermission()
    }
    override public func viewWillDisappear(_ animated: Bool) {
        log.debug("mapview will disappear")
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        log.debug("mapview received memory warning")
    }    
    public var isUserInteractionEnabled : Bool {
        set {
            mapView.isUserInteractionEnabled = newValue
        }
        get {
            return mapView.isUserInteractionEnabled
        }
    }
}

