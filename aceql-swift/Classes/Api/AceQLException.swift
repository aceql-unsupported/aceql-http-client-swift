//
//  AceQLException.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

public class AceQLException: Error {
    /// <summary>
    /// The HTTP status code.
    /// </summary>
    var httpStatusCode: Int = 0
    
    /// <summary>
    /// The reason.
    /// </summary>
    var reason: String = ""
    
    /// <summary>
    /// The error type.
    /// </summary>
    var errorType: Int = 0
    
    /// <summary>
    /// The remote stack trace.
    /// </summary>
    var remoteStackTrace: String = ""

    static var Instance: AceQLException? = nil
    
    init()
    {
        
    }
    
    static func ThrowException(type: Int, httpCode: Int, httpStatus: String, description: String)
    {
        if (Instance == nil)
        {
            Instance = AceQLException()
        }
        
        Instance?.httpStatusCode = httpCode
        Instance?.remoteStackTrace = httpStatus
        Instance?.errorType = type
        Instance?.reason = description
    }
    
    static func GetLastError() -> AceQLException?
    {
        if (Instance == nil)
        {
            Instance = AceQLException()
        }
        
        return Instance
    }
}
