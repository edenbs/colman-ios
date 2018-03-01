//
//  OfflineHelper.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 25/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import Foundation
import ReachabilitySwift
class OfflineHelper {
   
    
    
    static func isOnline()-> Bool{
        var stat = ReachabilityManager.shared.reachability.currentReachabilityStatus
        print("NIGHT!")
        print(ReachabilityManager.shared.reachability.currentReachabilityStatus)
        print("isOnline \(stat != Reachability.NetworkStatus.notReachable)")
        return stat != Reachability.NetworkStatus.notReachable
        
    }
    
}
