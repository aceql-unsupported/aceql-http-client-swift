//
//  RowParser.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

class RowParser {
    var jsonResult: [String: Any]?
    
    /// <summary>
    /// The trace on
    /// </summary>
    var traceOn: Bool = false
    /// <summary>
    /// The values per col index
    /// </summary>
    var valuesPerColIndex: [Int: Any]? = nil
    var typesPerColIndex: [Int: String]? = nil
    var colIndexesPerColName: [String: Int]? = nil;
    
    //private IFile file;
    
    /// <summary>
    /// Constructor
    /// </summary>
    /// <param name="readStream">The reading stream on file.</param>
    init(jsonResult: [String: Any]?)
    {
        self.jsonResult = jsonResult
        
        //file = AceQLCommandUtil.GetTraceFileAsync().Result;
        buildTypes();
    }
    
    func getTypesPerColIndex() -> [Int: String]?
    {
        return typesPerColIndex
    }
    
    func getValuesPerColIndex() -> [Int: Any]?
    {
        return valuesPerColIndex
    }
    
    
    func  getColIndexesPerColName() -> [String: Int]?
    {
        return colIndexesPerColName;
    }
    
    func buildTypes()
    {
        let columnTypes = jsonResult!["column_types"] as! [String]
        
        typesPerColIndex = [Int: String]()
        var index = 0
        for colType in columnTypes {
            typesPerColIndex![index] = colType
            index = index + 1
        }
    }
    
    /// <summary>
    /// Builds the row number.
    /// </summary>
    /// <param name="rowNum">The row number.</param>
    func buildRowNum(rowNum: Int)
    {
        // Value needed because we don't want to take columns with "row_xxx" names as row numbers
        
        var colIndex = 0
        var colname: String
        
        var queryRows = jsonResult!["query_rows"] as! [Any]
        var rowDic = queryRows[rowNum - 1] as! [String: Any]
        let columns = rowDic["row_" + String(rowNum)] as! [Any]
        
        //let rowDic = queryRows["row_" + String(rowNum)] as! [String: String]
        
        valuesPerColIndex = [Int: Any]()
        colIndexesPerColName = [String: Int]()
        
        for column in columns {
            let columnDic = column as! [String: Any]
            colname = Array(columnDic.keys)[0]
            var colValue: String? = String(describing: Array(columnDic.values)[0])

            if (colValue == "NULL")
            {
                colValue = nil
            }
            else {
                colValue = colValue?.trimmingCharacters(in: .whitespaces)
            }

            valuesPerColIndex![colIndex] = colValue

            if (rowNum == 1) {
                colIndexesPerColName![colname] = colIndex
            }
            colIndex = colIndex + 1
        }
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
    func SetTraceOn(traceOn: Bool)
    {
        self.traceOn = traceOn;
    }
    
    /// <summary>
    /// Traces this instance.
    /// </summary>
    func Trace()
    {
        if (traceOn)
        {
            ConsoleEmul.WriteLine();
        }
    }
    
    /// <summary>
    /// Traces the specified s.
    /// </summary>
    /// <param name="s">The s.</param>
    func Trace(log: String)
    {
        if (traceOn)
        {
            ConsoleEmul.WriteLine(log: log);
        }
    }
}
