//
//  CoreMotion+Extensions.swift
//  FloorDetector
//
//  Created by Julien Goudet on 21/06/2019.
//  Copyright © 2019 Hootcode. All rights reserved.
//

import Foundation
import CoreMotion



extension CMMotionActivity {
    
    var activityImageName: String {
        
        switch (unknown, stationary, walking, running, cycling, automotive) {
        case (true,_,_,_,_,_):
            return "unknown"
        case (_,true,_,_,_,_):
            return "stationary"
        case (_,_,true,_,_,_):
            return "walking"
        case (_,_,_,true,_,_):
            return "running"
        case (_,_,_,_,true,_):
            return "cycling"
        case (_,_,_,_,_,true):
            return "elevator"
        default:
            return "unknown"
        }
        
    }
    
    open override var debugDescription: String {
        var modes: Array<String> = []
        
        switch confidence {
        case .low:
            modes.append("🙁\n")
        case .medium:
            modes.append("😐\n")
        case .high:
            modes.append("🙂\n")
        @unknown default:
            print("unknown use case")
        }
        
        if unknown {
            modes.append("🤷‍♂️")
        }
        
        if stationary {
            modes.append("🕴")
        }
        
        if walking {
            modes.append("🚶‍")
        }
        
        if running {
            modes.append("🏃‍")
        }
        
        if cycling {
            modes.append("🚴‍")
        }
        
        if automotive {
            modes.append("🚗")
        }
        
        return modes.joined(separator: ", ")
    }

}

extension CMMotionActivityConfidence: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .low:
            return "low"
        case .medium:
            return "medium"
        case .high:
            return "high"
        @unknown default:
            fatalError()
        }
    }
}
