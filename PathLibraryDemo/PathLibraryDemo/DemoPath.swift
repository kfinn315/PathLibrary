//
//  DemoPath.swift
//  PathLibraryDemo
//
//  Created by Kevin Finn on 3/28/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import PathMap
import CoreLocation
import RandomKit

public class DemoPath : NSObject, IPathBase {
    public static func random() -> DemoPath{
        let path = DemoPath()
        
        var locs : [CLLocationCoordinate2D] = []
        
        for _ in 0 ... Int.random(in: 0...20, using: &Xorshift.default)
        {
            locs.append(CLLocationCoordinate2D.init(latitude: CLLocationDegrees.random(using: &Xorshift.default), longitude: CLLocationDegrees.random(using: &Xorshift.default)))
        }
        
        path.points = locs
        return path
    }
    
    public override init() {
        
    }
    
    public var displayTitle: String {
        return title ?? ""
    }
    
    public var displayDuration: String{
        return duration?.description ?? ""
    }
    
    public var displayDistance: String?
    
    public var localid: String?
    
    public var title: String?
    
    public var notes: String?
    
    public var startdate: Date?
    
    public var enddate: Date?
    
    public var duration: NSNumber?
    
    public var distance: NSNumber?
    
    public var stepcount: NSNumber?
    
    public var pointsJSON: String?
    
    public var albumId: String?
    
    public var coverimg: Data?
    
    public var locations: String?
    
    public var points : [CLLocationCoordinate2D] = []
    
    public func getSimplifiedCoordinates() -> [CLLocationCoordinate2D] {
        return getPoints()
    }
    
    public func getSteps(_ callback: @escaping (NSNumber?) -> Void) {
        
    }
    
    public func updatePhotoAlbum(collectionid: String) {
        albumId = collectionid
    }
    
    public func getPoints() -> [CLLocationCoordinate2D] {
        return points
    }
    
    
}
