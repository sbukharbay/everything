//
//  Async.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 02/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public func asyncAfter(_ deadline: DispatchTime, _ execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: deadline, execute: execute)
}

public func asyncAfter(_ interval: DispatchTimeInterval, _ execute: @escaping () -> Void) {
    asyncAfter(.now() + interval, execute)
}

public func asyncAlways(_ execute: @escaping () -> Void) {
    DispatchQueue.main.async(execute: execute)
}

public func asyncIfRequired(_ execute: @escaping () -> Void) {
    if Thread.isMainThread {
        execute()
    } else {
        DispatchQueue.main.async(execute: execute)
    }
}

public func syncIfRequired(_ execute: @escaping () -> Void) {
    if Thread.isMainThread {
        execute()
    } else {
        DispatchQueue.main.sync(execute: execute)
    }
}
