//
//  PriorityQueue.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class PriorityQueue<T : AnyObject> {
    public var elems : [T] = [T]()
    
    public let compare : (lhs : T,rhs : T) -> Int
    public init(compare : (lhs : T,rhs : T) -> Int) {
        self.compare = compare
    }
    
    public func getElements() -> [T] {
        return [T](elems);
    }
    
    public func doesInclude(elem : T) -> Bool {
        for el in elems {
            if (el === elem) {
                return true
            }
        }
        return false
    }
    
    public func push(elem : T) -> T {
        var upper = elems.count - 1
        var lower = 0
        if upper > -1 {
            while upper >= lower {
                let idx = lower + (upper - lower)/2
                let comp = compare(lhs: elem, rhs: elems[idx])
                if (comp == 0) {
                    elems.insert(elem, atIndex: idx)
                    return elem
                } else if (comp < 0) {
                    upper = idx - 1
                } else if (comp > 0) {
                    lower = idx + 1
                }
            }
        }
        elems.insert(elem, atIndex: lower)
        return elem
    }
    
    public func poll() -> T? {
        if elems.count > 0 {
            return elems.removeLast()
        }
        return nil
    }
    
    public func peek() -> T? {
        if elems.count > 0 {
            return elems.last
        }
        return nil
    }
    
    public func delete(elem : T) -> T? {
        for( var i = 0; i < elems.count; i++) {
            if (compare(lhs: elem, rhs: elems[i]) == 0) {
                return elems.removeAtIndex(i)
            }
        }
        return nil
    }
}