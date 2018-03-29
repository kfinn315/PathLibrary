//
//  IPath.swift
//  PathData
//
//  Created by Kevin Finn on 3/28/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import CoreData
import CoreLocation

protocol IPathBase : AnyObject {
    
    var displayTitle : String {get}
    var displayDuration : String {get}
    var displayDistance : String? {get}
    var localid : String? {get set}
    var title : String? {get set}
    var notes : String? {get set}
    var startdate : Date? {get set}
    var enddate : Date? {get set}
    var duration : NSNumber? {get set}
    var distance : NSNumber? {get set}
    var stepcount : NSNumber? {get set}
    var pointsJSON : String? {get set}
    var albumId : String? {get set}
    var coverimg : Data? {get set}
    var locations : String? {get set}
    
}

protocol IPath : IPathBase {
    init()
    init(entity: NSManagedObject)
    init(_ context: NSManagedObjectContext)
    func setPoints(_ points: IPoints)
    func setTimes(start: Date, end: Date)
    //func save()
    func update(_ entity: NSManagedObject)
    func getSimplifiedCoordinates() -> [CLLocationCoordinate2D]
    func getSteps(_ callback: @escaping (NSNumber?) -> Void)
    //func getSnapshot(_ callback: @escaping (UIImage?) -> Void)
    func updatePhotoAlbum(collectionid: String)
    func getPoints() -> [CLLocationCoordinate2D]
    
    var entitydescription : NSEntityDescription {get}
    var identity : String {get}
    
}
