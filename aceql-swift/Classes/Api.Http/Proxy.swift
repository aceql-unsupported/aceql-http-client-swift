//
//  Proxy.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

class Proxy {
    var userName: String = ""
    var password: String = ""
    var proxyUri: String
    
    /// <summary>
    /// Builds an  <see cref="IWebProxy"/> implementation.
    /// </summary>
    /// <param name="proxyUri">The proxy URI. Example: http://localhost:8080.</param>
    ///
    init(proxyUri: String)
    {
        self.proxyUri = proxyUri
    }
    
    func GetProxy() -> URL
    {
        return URL(string: self.proxyUri)!
    }
    
    func isBypassed(host: URL) -> Bool
    {
        return false;
    }
}
