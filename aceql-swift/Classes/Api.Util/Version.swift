//
//  Version.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

class Version {
    static func GetVersion() -> String
    {
        return VersionValues.PRODUCT + " " + VersionValues.VERSION + " - " + VersionValues.DATE
    }
}
