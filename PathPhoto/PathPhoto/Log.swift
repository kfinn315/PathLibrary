//
//  Log.swift
//  PathData
//
//  Created by Kevin Finn on 3/27/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import SwiftyBeaver

//let log = SwiftyBeaver.self

var log : SwiftyBeaver.Type = {
    var console = ConsoleDestination()
    console.minLevel = .verbose
    SwiftyBeaver.addDestination(console)
    return SwiftyBeaver.self
}()
