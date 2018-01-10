//
//  AceQLCredential.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

open class AceQLCredential {
    var username: String
    var password: String
    
    /// <summary>
    /// Creates an object of type <see cref="AceQLCredential"/>.
    /// </summary>
    /// <param name="username">The username.</param>
    /// <param name="password">The password.</param>
    /// <exception cref="System.ArgumentNullException">If username or password is null. </exception>
    init(username: String, password: String)
    {
        self.username = username
        self.password = password
    }
}
