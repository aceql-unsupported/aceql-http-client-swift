//
//  StreamResultAnalyzer.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

class StreamResultAnalyzer {
    /// <summary>
    /// The error identifier
    /// </summary>
    var errorType: String = ""
    /// <summary>
    /// The error message
    /// </summary>
    var errorMessage: String = ""
    /// <summary>
    /// The stack trace
    /// </summary>
    var stackTrace: String = ""
    
    var httpStatusCode: HTTPURLResponse
    
    // The JSON file containing Result Set
//    var file: URL
    
    var jsonResult: [String: Any]?
    
    
    /// <summary>
    /// Initializes a new instance of the <see cref="StreamResultAnalyzer"/> class.
    /// </summary>
    /// <param name="file">The file to analyze.</param>
    /// <param name="httpStatusCode">The http status code.</param>
    /// <exception cref="System.ArgumentNullException">The file is null.</exception>
//    init(file: URL?, httpStatusCode: HTTPURLResponse)
//    {
//        self.file = file!
//        self.httpStatusCode = httpStatusCode
//    }
    
    init(jsonResult: [String: Any]?, httpStatusCode: HTTPURLResponse)
    {
        self.jsonResult = jsonResult
        self.httpStatusCode = httpStatusCode
    }
    
    /// <summary>
    /// Determines whether the SQL correctly executed on server side.
    /// </summary>
    /// <returns><c>true</c> if [is status ok]; otherwise, <c>false</c>.</returns>
    func isStatusOkAsync() -> Bool
    {
//        let text = try? String(contentsOf: file, encoding: String.Encoding.utf8)
//
//        let data = text!.data(using: .utf8)
//
//        let jsonResult : [String: Any]
//        do {
//            jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
//        } catch {
//            print(error.localizedDescription)
//            return false
//        }
//
        if (jsonResult == nil)
        {
            return false;
        }
        if (String(describing: jsonResult!["status"]!) == "OK") {
            return true
        }
        
        parseErrorKeywords(jsonResult: jsonResult)
        return false
       
    }
    
    /// <summary>
    /// Parses the error keywords.
    /// </summary>
    /// <param name="reader">The reader.</param>
    func parseErrorKeywords(jsonResult: [String: Any]?)
    {
        errorType = String(describing: jsonResult!["error_type"])
        
        errorMessage = String(describing: jsonResult!["error_message"])
        
        stackTrace = String(describing: jsonResult!["stack_trace"])
    }
    
    /// <summary>
    /// Gets the error message.
    /// </summary>
    /// <returns>The error message</returns>
    func getErrorMessage() -> String
    {
        return self.errorMessage
    }
    
    /// <summary>
    /// Gets the error type.
    /// </summary>
    /// <returns>The error type.</returns>
    func getErrorType() -> Int
    {
        return Int(self.errorType)!
    }
    
    /// <summary>
    /// Gets the remote stack trace.
    /// </summary>
    /// <returns>The remote stack trace.</returns>
    func GetStackTrace() -> String
    {
        return self.stackTrace
    }
}

