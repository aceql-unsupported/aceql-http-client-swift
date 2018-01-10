//
//  Version.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

class Version {
    static func GetVersion() -> String
    {
        return VersionValues.PRODUCT + " " + VersionValues.VERSION + " - " + VersionValues.DATE
    }
}
