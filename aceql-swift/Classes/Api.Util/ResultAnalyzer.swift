//
//  ResultAnalyzer.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

class ResultAnalyzer {
    /// <summary>
    /// The json result
    /// </summary>
    var jsonResult: [String: Any]?
    var httpStatusCode: HTTPURLResponse?
    
    /// <summary>
    /// We try to find status. If error parsing, invalidJsonStream = true
    /// </summary>
    var invalidJsonStream: Bool = false
    
    /** Exception when parsing the JSON stream. Future usage */
//    private Exception parseException = null;
    
    /// <summary>
    /// Initializes a new instance of the <see cref="ResultAnalyzer"/> class.
    /// </summary>
    /// <param name="jsonResult">The json result.</param>
    /// <param name="httpStatusCode">The http status code.</param>
    /// <exception cref="System.ArgumentNullException">jsonResult is null!</exception>
    init (jsonResult: [String: Any]?, httpStatusCode: HTTPURLResponse?)
    {
        self.httpStatusCode = httpStatusCode;
        self.jsonResult = jsonResult;
    }
    
    /// <summary>
    /// Determines whether the SQL command correctly executed on server side.
    /// </summary>
    /// <returns><c>true</c> if [is status ok]; otherwise, <c>false</c>.</returns>
    func isStatusOk() -> Bool
    {
        if (jsonResult == nil)
        {
            return false
        }
        
        if (String(describing: jsonResult!["status"]!) == "OK") {
            return true
        }
        
        return false
    }
    
    
    /// <summary>
    /// Says if the JSON Stream is invalid.
    /// </summary>
    /// <returns>true if JSN stream is invalid</returns>
    func isInvalidJsonStream() -> Bool
    {
        if (jsonResult == nil)
        {
            return true;
        }
        
        if (invalidJsonStream)
        {
            return true;
        }
        
        return false;
    }
    
    /// <summary>
    /// Gets the result for a a key name
    /// </summary>
    /// <param name="name">The name.</param>
    /// <returns>System.String.</returns>
    func getResult(name: String) -> String?
    {
        return getValue(name: name);
    }
    
    /// <summary>
    /// Gets the result for the key name "result"
    /// </summary>
    /// <returns></returns>
    func GetResult() -> String?
    {
        return getValue(name: "result")
    }
    
    /// <summary>
    /// Gets the value.
    /// </summary>
    /// <param name="name">The name.</param>
    /// <returns>System.String.</returns>
    /// <exception cref="System.ArgumentNullException">name is null!</exception>
    /// <exception cref="System.Exception">Illegal name: " + name</exception>
    func getValue(name: String) -> String?
    {
        if (isInvalidJsonStream())
        {
            return nil
        }
    
        if (jsonResult![name] == nil)
        {
            return nil
        }
        
        return String(describing: jsonResult![name]!)
    }
    
    /// <summary>
    /// Gets the error_type.
    /// </summary>
    /// <returns>System.Int32.</returns>
    func getErrorId() -> Int
    {
        if (isInvalidJsonStream())
        {
            return 0
        }
    
        return jsonResult!["error_type"] as! Int
    }
    
    /// <summary>
    /// Gets the error_message.
    /// </summary>
    /// <returns>System.String.</returns>
    func getErrorMessage() -> String
    {
        if (isInvalidJsonStream())
        {
            var theErrorMessage = "Unknown error.";
            if (httpStatusCode?.statusCode != 200)
            {
                theErrorMessage = "HTTP FAILURE + (\(String(describing: httpStatusCode?.statusCode))) +  ( + httpStatusCode + )";
            }
            
            return theErrorMessage;
        }
        
        return jsonResult!["error_message"] as! String
    }
    
    /// <summary>
    /// Gets the remote stack_trace.
    /// </summary>
    /// <returns>String.</returns>
    func getStackTrace() -> String?
    {
        if (isInvalidJsonStream())
        {
            return nil
        }
        
        return jsonResult!["stack_trace"] as? String
    }
    
    /// <summary>
    /// Gets the int value.
    /// </summary>
    /// <param name="name">The name.</param>
    /// <returns>System.Int32.</returns>
    func GetIntvalue(name: String) -> Int
    {
        let insStr = getValue(name: name);
        
        if (insStr == nil)
        {
            return -1;
        }
        
        return Int(insStr!)!
    }
}
