//
//  PathManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/9/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import UIKit
import CoreMotion
import RxCocoa
import RxSwift
import RxCoreData
import MapKit

protocol IPathManager : AnyObject {
    var currentPathObservable : Observable<IPath?>? {get}
    var hasNewPath : Bool {get set}
    static var distanceFormatter: MKDistanceFormatter{get}
    static var dateFormatter: DateComponentsFormatter{get}
    
    func updateCurrentAlbum(collectionid: String)
    func setCurrentPath(_ path: IPath?)
    func getNewPath() -> Path
    func save(path: IPath?, callback: @escaping (IPath?,Error?) -> Void)
    func updateCurrentPathInCoreData(notify: Bool) throws 
    func getAllPaths() -> [Path]?
}

/**
 Path takes in a list of CLLocation2D and calculates: distance, duration, creates an image
 It stores an asset collection of photos
 */

/**
 PathMapView shows the Path on the map.  It shows the photos in the position they were taken (location data exists)
 */



/**
 Manages the retrieval and updating of Paths in CoreData and sets the current Path
 */
class PathManager : IPathManager {
    static let distanceFormatter = MKDistanceFormatter()
    static let dateFormatter = DateComponentsFormatter()
    static let lineTolerance : Float = 0.000005
    
    public var currentPathObservable : Observable<IPath?>?
    public var hasNewPath : Bool = false
    
    private var pointsManager : IPointsManager = PointsManager(context: PathManager.managedObjectContext)
    public static var pedometer = CMPedometer()
    private var disposeBag = DisposeBag()
    fileprivate var _currentPath : IPath? {
        didSet{
           currentPathSubject.onNext(_currentPath)
        }
    }
    private let currentPathSubject = BehaviorSubject<IPath?>(value: nil)
    
    private static var _shared : PathManager?
    public static var managedObjectContext : NSManagedObjectContext!
    
    class var shared : PathManager {
        if _shared == nil {
            _shared = PathManager()
        }
        
        return _shared!
    }
    
    required init() {
        setup()
    }
    
    private func setup(){
        currentPathObservable = currentPathSubject.observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
    }
    
    public func getNewPath() -> Path {
        return Path()
    }
    
    public func updateCurrentAlbum(collectionid: String) {
        guard let currentPath = _currentPath else {
            return
        }

        currentPath.updatePhotoAlbum(collectionid: collectionid)

        do{
            try updateCurrentPathInCoreData(notify: false)
        } catch{
            log.error(error.localizedDescription)
        }
    }
    
    public var currentPath: IPath? {
        return _currentPath
    }
    
    public func setCurrentPath(_ path: IPath?) {
        if _currentPath?.identity != path?.identity {
            _currentPath = path
        }
    }
    
    public func save(path: IPath?, callback: @escaping (IPath?,Error?) -> Void) {
        guard let path = path else {
            callback(nil, LocalError.failed(message: "Path was nil"))
            return
        }
        
        if let points = pointsManager.fetchPoints(), let path = path as? Path {
            path.setPoints(points)
            PathManager.managedObjectContext?.insert(path)
        }
        
        self.setCurrentPath(path)
        self.hasNewPath = true
        
        callback(path, nil)
    }
   
    public func updateCurrentPathInCoreData(notify: Bool = true) throws {
        log.info("call to update current path")
        
        guard let currentpath = _currentPath as? Path else {
            log.error("currentpath value is nil or not Path type")
            return
        }
        
        log.debug("update current path in managedObjectContext")
        try PathManager.managedObjectContext!.rx.update(currentpath)
        
        if(notify){
            currentPathSubject.onNext(currentpath) //necessary?
        }
        
        hasNewPath = false
    }
    
    public func getAllPaths() -> [Path]?{
        let request: NSFetchRequest<Path> = Path.fetchRequest()
        //        let predicate = NSPredicate(format: "distance > %d", 5)
        //        request.predicate = predicate
        do{
            let result = try PathManager.managedObjectContext?.fetch(request)
            return result
        } catch{
            //error
            log.error(error.localizedDescription)
        }
        
        return nil
    }
    
    public var pathCount : Int {
        var count : Int? = 0

        do{
            let request: NSFetchRequest<Path> = Path.fetchRequest()
            count = try PathManager.managedObjectContext?.count(for: request)
        } catch{
            log.error(error.localizedDescription)
        }
        
        return count ?? 0
    }
}
