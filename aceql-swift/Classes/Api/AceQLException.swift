//
//  AceQLException.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

enum AceQLException: String, Error {
    case missedServer = "Server keyword not found in connection string."
    case missedUsername = "Username keyword not found in connection string or AceQLCredential not set."
    case missedPassword = "Password keyword not found in connection string or AceQLCredential not set"
    case missedDatabase = "Database keyword not found in connection string."
}
