//
//  AllMapViewController.swift
//  paths
//
//  Created by Kevin Finn on 2/26/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import CoreData

/**
 ViewController that displays all the Path objects saved in CoreData
 */
public class AllMapViewController : UIViewController {
    static let storyboardIdentifier : String = "All Paths"
    var paths : [IPathBase]? = nil
    public static var instance : AllMapViewController {
        return UIStoryboard.init(name: "MapStoryboard", bundle: Bundle(for: AllMapViewController.self)).instantiateViewController(withIdentifier: AllMapViewController.storyboardIdentifier) as! AllMapViewController
    }
    
    @IBOutlet weak var mapView: MapView!
    
    //    public var overlays : [MKOverlay] = []
    public var boundingRect : MKMapRect? = nil
    private let mapViewDelegate = MapViewDelegate()
    //private var disposeBag = DisposeBag()
    
    override public func viewDidLoad() {
        //let paths = PathManager.shared.getAllPaths()
        
        mapView.delegate = mapViewDelegate
        //
        //        let fetchRequest : NSFetchRequest<Path> = Path.fetchRequest()
        //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "title", ascending: false)]
        //        PathManager.managedObjectContext.rx.entities(fetchRequest: fetchRequest).asObservable().observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive)).subscribe(onNext: { (paths) in
        //
        //        }).disposed(by: disposeBag)
        
        update()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        
    }
    
    public func load(paths: [IPathBase]){
        self.paths = paths
        update()
    }
    
    public func update(){
        
        if viewIfLoaded != nil, let paths = paths {
            self.mapView.clear()
            //self.overlays = []
            self.mapView.removeOverlays()
            var overlays : [MKOverlay] = []
            var annotations : [PathAnnotation] = []
            paths.forEach({ (path) in
                let coords = path.getSimplifiedCoordinates()
                let polyline = MKPolyline(coordinates: coords, count: coords.count)
                if self.boundingRect == nil {
                    self.boundingRect = polyline.boundingMapRect
                } else {
                    self.boundingRect = MKMapRectUnion(self.boundingRect!, polyline.boundingMapRect)
                }
                overlays.append(polyline)
                
                if let startCoord = coords.first {
                    let annotation = PathAnnotation()
                    annotation.coordinate = startCoord
                    annotation.title = path.displayTitle
                    annotation.subtitle = path.displayDistance
                    annotations.append(annotation)
                }
            })
            DispatchQueue.main.async {
                self.mapView.addAnnotations(annotations)
                self.mapView.addOverlays(overlays)
            }
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let boundingRect = boundingRect {
            let zoomRect = mapView.mapRectThatFits(boundingRect)
            if(!MKMapRectIsEmpty(zoomRect)) {
                mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(5, 5, 5, 5), animated: false)
            }
            
        }
    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.removeOverlays()
        mapView.delegate = nil
    }
}

class PathAnnotation : MKPointAnnotation {
    
}
