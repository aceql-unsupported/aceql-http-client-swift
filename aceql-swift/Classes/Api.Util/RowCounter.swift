//
//  RowCounter.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

class RowCounter {
    var traceOn: Bool = true
    var jsonResult : [String: Any]?
    var file: URL?
    
    /// <summary>
    /// Constructor
    /// </summary>
    /// <param name="file">The Result Set JSON file to count the rows for.</param>
    /// <exception cref="System.ArgumentNullException">The file is null.</exception>
//    init(file: URL)
//    {
//        self.file = file
//    }
    
    init(jsonResult: [String: Any]?)
    {
        self.jsonResult = jsonResult
    }
    
    /// <summary>
    /// Gets the row count.
    /// </summary>
    /// <returns>System.Int32.</returns>
    func countAsync() -> Int
    {
        trace()
        
//        let text = try? String(contentsOf: file!, encoding: String.Encoding.utf8)
//
//        let data = text!.data(using: .utf8)
//
//        let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
        if (jsonResult == nil)
        {
            return 0
        }
        
        let rowCount = jsonResult!["row_count"] as! Int
        
        trace()
        trace(theString: "rowCount: " + String(describing: rowCount))
        
        return rowCount
    }
    
    
    /**
     * Says if trace is on
     *
     * @return true if trace is on
     */
    /// <summary>
    /// Determines whether [is trace on].
    /// </summary>
    /// <returns><c>true</c> if [is trace on]; otherwise, <c>false</c>.</returns>
    func isTraceOn() -> Bool
    {
        return traceOn;
    }
    
    /**
     * Sets the trace on/off
     *
     * @param traceOn
     *            if true, trace will be on
     */
    /// <summary>
    /// Sets the trace on.
    /// </summary>
    /// <param name="traceOn">if set to <c>true</c> [trace on].</param>
    func setTraceOn(traceOn: Bool)
    {
        self.traceOn = traceOn;
    }
    
    /// <summary>
    /// Traces this instance.
    /// </summary>
    func trace()
    {
        if (traceOn)
        {
            ConsoleEmul.WriteLine();
        }
    }
    
    /// <summary>
    /// Traces the specified string.
    /// </summary>
    /// <param name="theString">The string to trace.</param>
    func trace(theString: String)
    {
        if (traceOn)
        {
            ConsoleEmul.WriteLine(log: theString);
        }
    }
}
