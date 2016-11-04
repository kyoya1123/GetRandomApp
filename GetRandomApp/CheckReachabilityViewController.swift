//
//  CheckReachabilityViewController.swift
//  GetRandomApp
//
//  Created by Family Account on 2016/11/02.
//  Copyright © 2016年 Family Account. All rights reserved.
//

import SystemConfiguration

func CheckReachability(host_name:String)->Bool{
    
    let reachability = SCNetworkReachabilityCreateWithName(nil, host_name)!
    var flags = SCNetworkReachabilityFlags.connectionAutomatic
    if !SCNetworkReachabilityGetFlags(reachability, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
}
