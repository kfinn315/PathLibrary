//
//  MapView.swift
//  paths
//
//  Created by Kevin Finn on 3/9/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import MapKit
import UIKit

/**
 MKMapView subclass that adds functions for displaying Paths
 */
class MapView : MKMapView {
    var polyline : MKPolyline?
    
    public func setImageAnnotations(_ annotations : [MKAnnotation]) {
        let group = DispatchGroup()
        DispatchQueue.main.async {
            group.enter()
            self.removeImageAnnotations()
            group.leave()
        }
        
        group.wait()
        
        DispatchQueue.main.async {
            log.debug("add image annotations to map")
            self.addAnnotations(annotations)
        }
    }
    
    public func removeImageAnnotations(){
        log.debug("IMG remove annotations")
        removeAnnotations((annotations.filter() {
            $0 is ImageAnnotation
        }))
    }
    
    public func removePathAnnotations(){
        log.debug("PATH remove annotations")
        removeAnnotations((annotations.filter() {
            !($0 is ImageAnnotation)
        }))
    }
    
    public var pathAnnotations : [MKAnnotation] {
        return annotations.filter { !($0 is ImageAnnotation)}
    }
        
    public func removeOverlays(){
        log.debug("PATH remove overlays")
        removeOverlays(overlays)
    }
    
    public func clear(){
        self.removePathAnnotations()
        self.removeImageAnnotations()
        self.removeOverlays()
    }
    
    public func load(coordinates: [CLLocationCoordinate2D]) {
        log.debug("PATH loadPath")
     //   let coordinates = path?.getSimplifiedCoordinates() ?? []
        
        DispatchQueue.global(qos: .userInitiated).sync {
            log.debug("PATH create polyline from coordinates")

            self.removePathAnnotations()
            self.removeOverlays()

            self.polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            removePathAnnotations()
            
            //add annotation to first and last coords
            if let firstcoord = coordinates.first {
                let firstpin = MKPointAnnotation()
                firstpin.coordinate = firstcoord
                self.addAnnotation(firstpin)
            }
            if coordinates.count > 1, let lastcoord = coordinates.last {
                let lastpin = MKPointAnnotation()
                lastpin.coordinate = lastcoord
                self.addAnnotation(lastpin)
            }
        }
        if let polyline = self.polyline {
            DispatchQueue.main.async {
                log.debug("PATH draw polyline on map")
                self.add(polyline)
                self.zoomToContent()
            }
        }
    }
    private func zoomToContent(){
        if let polyline = polyline {
            let boundingRect = polyline.boundingMapRect
            setVisibleMapRect(boundingRect, edgePadding:  UIEdgeInsetsMake(25.0,25.0,25.0,25.0), animated: false)
            if camera.altitude < 200 {
                camera.altitude = 1000
            }
        } else{
            zoomToPathAnnotations()
        }
    }
    
    private func zoomToPoint(_ point: CLLocation, animated: Bool) {
        log.debug("mapview zoom to point")
        var zoomRect = MKMapRectNull
        let mappoint = MKMapPointForCoordinate(point.coordinate)
        let pointRect = MKMapRectMake(mappoint.x, mappoint.y, 0.1, 0.1)
        zoomRect = MKMapRectUnion(zoomRect, pointRect)
        setVisibleMapRect(zoomRect, animated: true)
    }
    
    private func zoomToFit() {
        log.debug("mapview zoom to fit")
        setVisibleMapRect(getZoomRect(from: annotations), animated: true)
    }
    private func zoomToPathAnnotations() {
        setVisibleMapRect(getZoomRect(from: pathAnnotations), animated: false)
    }
    private func getZoomRect(from annotations: [MKAnnotation]) -> MKMapRect {
        var zoomRect = MKMapRectNull
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        return zoomRect
    }
    
    //MARK:Snapshot
    public static func getSnapshot(from points: [CLLocationCoordinate2D], _ callback: @escaping (UIImage?, Error?)->()) {
        let options = MKMapSnapshotOptions()
        options.mapRect = getZoomRect(from: points)
        if #available(iOS 11.0, *) {
            options.mapType = MKMapType.mutedStandard
        }
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { (snapshot, error) in
            guard let snapshot = snapshot else{
                callback(nil, LocalError.failed(message: "snapshot was nil")) //create error
                return
            }
            
            //draw on img here
            let image = drawLineOnImage(size: snapshot.image.size, coords: points, snapshot: snapshot)
            
            callback(image, nil)
        }
    }
    private static func getZoomRect(from coords: [CLLocationCoordinate2D]) -> MKMapRect {
        var zoomRect = MKMapRectNull
        
        for coord in coords {
            let point = MKMapPointForCoordinate(coord)
            let pointRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        
        return MKMapRectInset(zoomRect, -5.0, -5.0)
    }
    private static func drawLineOnImage(size: CGSize, coords: [CLLocationCoordinate2D], snapshot: MKMapSnapshot) -> UIImage {
        let image = snapshot.image
        
        // for Retina screen
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // draw original image into the context
        image.draw(at: .zero)
        
        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()
        
        // remove map from image by adding a clear rectangle
        let rect = CGRect(origin: .zero, size: image.size)
        UIColor.clear.setFill()
        UIRectFill(rect)
        
        UIColor.orange.setStroke()
        
        // set stroking width and color of the context
        context!.setLineWidth(8.0)
        context!.setStrokeColor(UIColor.orange.cgColor)
        
        context!.move(to: snapshot.point(for: coords[0]))
        for i in 0...coords.count-1 {
            context!.addLine(to: snapshot.point(for: coords[i]))
            context!.move(to: snapshot.point(for: coords[i]))
        }
        
        // apply the stroke to the context
        context!.strokePath()
        
        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
}
