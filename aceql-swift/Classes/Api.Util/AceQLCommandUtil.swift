//
//  AceQLCommandUtil.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

class AceQLCommandUtil {
    var DEBUG: Bool = false
    
    /// <summary>
    /// The command text
    /// </summary>
    var cmdText: String
    /// <summary>
    /// The parameters
    /// </summary>
    var parameters: AceQLParameterCollection
    
    /// <summary>
    /// The BLOB ids
    /// </summary>
    var blobIds: [String] = [String]()
    /// <summary>
    /// The BLOB file streams
    /// </summary>
    var blobStreams = [Data?]()
    
    var blobLengths = [Int64]();
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLCommandUtil"/> class.
    /// </summary>
    /// <param name="cmdText">The command text.</param>
    /// <param name="Parameters">The parameters.</param>
    /// <exception cref="System.ArgumentNullException">
    /// cmdText is null!
    /// or
    /// Parameters is null!
    /// </exception>
    init(cmdText: String, parameters: AceQLParameterCollection)
    {
        self.cmdText = cmdText
        self.parameters = parameters
    }
    
    
    /// <summary>
    /// Gets the prepared statement parameters.
    /// </summary>
    /// <returns>The Parameters List</returns>
    func getPreparedStatementParameters() -> [String: String]
    {
        let paramsIndexInPrepStatement: [String: Int] = getPreparedStatementParametersDic()
        
        //List<PrepStatementParameter> parametersList = new List<PrepStatementParameter>();
        
        var parametersList = [String: String]()
        
        // For each parameter 1) get the index 2) get the dbType
        for (paramKey, paramValue) in paramsIndexInPrepStatement
        {
            let aceQLParameter = parameters.getAceQLParameter(parameterName: paramKey)
            let paramIndex = String(describing: paramValue)
            let sqlType = aceQLParameter!.sqlType
            let value = aceQLParameter!.value
            
            debug(log: "paramIndex: " + String(paramIndex))
            debug(log: "value     : " + String(describing: value) + ":")
            
            if (aceQLParameter?.isNullValue)!
            {
                let paramType = "TYPE_NULL" + String(describing: Int((sqlType)!.rawValue))
                parametersList["param_type_" + String(paramIndex)] = paramType
                parametersList["param_value_" + String(paramIndex)] = "NULL"
            }
            else if (value is Data?)
            {
            // All streams are blob for now
            // This will be enhanced in future version
            
                let blobId = buildUniqueBlobId()
                
                blobIds.append(blobId);
                blobStreams.append(value as? Data);
                blobLengths.append(aceQLParameter!.blobLength)
                
                let paramType = "BLOB";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = blobId
            }
            else if (value is String)
            {
                let paramType = "VARCHAR";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = (value as! String)
            }
            else if (value is Int64)
            {
                let paramType = "BIGINT";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = String(describing: value as! Int64)
            }
            else if (value is Int)
            {
                let paramType = "INTEGER";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = String(describing: value as! Int)
            }
            else if (value is Int16)
            {
                let paramType = "TINYINT";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = String(describing: value as! Int16)
            }
            else if (value is Bool)
            {
                let paramType = "BIT";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = String(describing: value as! Bool)
            }
            else if (value is Float)
            {
                let paramType = "REAL";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = String(describing: value as! Float)
            }
            else if (value is Double)
            {
                let paramType = "DOUBLE_PRECISION";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = String(describing: value as! Double)
            }
            else if (value is Date)
            {
                let paramType = "TIMESTAMP";
                parametersList["param_type_" + paramIndex] = paramType
                parametersList["param_value_" + paramIndex] = convertToTimestamp(dateTime: value as! Date)
            }
//            else if (value is TimeSpan)
//            {
//                String paramType = "TIME";
//                parametersList.Add("param_type_" + paramIndex, paramType);
//                parametersList.Add("param_value_" + paramIndex, ConvertToTimestamp((DateTime)value));
//            }
            else
            {
//            throw new AceQLException("Type of value is not supported. Value: " + value + " / Type: " + value.GetType(), 2, (Exception)null, HttpStatusCode.OK);
            }
            
        }
        
        return parametersList;
    }
    
    /// <summary>
    /// Builds a unique Blob ID.
    /// </summary>
    /// <returns>a unique Blob ID.</returns>
    func buildUniqueBlobId() -> String
    {
        let blobId = String(arc4random()) + ".blob";
        return blobId;
    }
    
    /// <summary>
    /// Returns the file corresponding to the trace file. Value is: AceQLPclFolder/trace.txt.
    /// </summary>
    /// <returns>the file corresponding to the trace file.</returns>
    static func getTraceFileAsync() -> URL?
    {
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return dir.appendingPathComponent(Param.TRACE_TXT)
        }
        return nil;
    }
    
    /// <summary>
    /// Gets the prepared statement parameters dictionary.
    /// </summary>
    /// <returns>Dictionary&lt;String, System.Int32&gt;.</returns>
    /// <exception cref="System.ArgumentException">Invalid parameter not exists in SQL command: " + theParm</exception>
    func getPreparedStatementParametersDic() -> [String: Int]
    {
        let theParamsSet = getValidParams();
        
        var paramsIndexOf = [String]()
        
        if parameters.count() > 0 {
            for i in 0...parameters.count() - 1
            {
                if (DEBUG)
                {
                //ConsoleEmul.WriteLine(Parameters[i] + " / " + Parameters[i].Value);
                }
                
                let theParm = parameters.getIndex(index: i).parameterName
                
                if (!theParamsSet.contains(theParm))
                {
    //            throw new ArgumentException("Invalid parameter that not exists in SQL command: " + theParm);
                }
                
//                let index = cmdText.index(of: theParm)
//                let intValue = cmdText.distance(from: cmdText.startIndex, to: index!)
                paramsIndexOf.append(theParm)
            }
        }
        
        // Build the parameters
        var paramsIndexInPrepStatement = [String: Int]()
    
        var parameterIndex = 0;
        for value in paramsIndexOf
        {
            parameterIndex += 1
            paramsIndexInPrepStatement[value] = parameterIndex
        }
        return paramsIndexInPrepStatement;
    }
    
    /// <summary>
    /// Gets the valid parameters.
    /// </summary>
    /// <returns>HashSet&lt;System.String&gt;.</returns>
    func getValidParams() -> [String]
    {
        var theParamsSet = [String]()
        let separators = CharacterSet.init(charactersIn: "@,() =")
        var splits = cmdText.components(separatedBy: separators)
        
        for i in 0...splits.count - 1
        {
            if (splits[i] == "")
            {
                continue;
            }
            let validParam = "@" + splits[i]
            
            if (cmdText.contains(validParam))
            {
                theParamsSet.append(validParam);
            //ConsoleEmul.WriteLine(validParam);
            }
        }
    
        return theParamsSet;
    }
    
    /// <summary>
    /// Replaces the parms with question marks.
    /// </summary>
    /// <returns>System.String.</returns>
    func replaceParmsWithQuestionMarks() -> String
    {
        if (parameters.count() > 0) {
            for i in 0...parameters.count() - 1
            {
            //ConsoleEmul.WriteLine(Parameters[i] + " / " + Parameters[i].Value + " / " + Parameters[i].DbType);
            
                let theParm = parameters.getIndex(index: i).parameterName
                cmdText = cmdText.replacingOccurrences(of: theParm, with: "?")
            }
        }
        return cmdText;
    }
    
    
    /// <summary>
    /// Dates the time to unix timestamp.
    /// </summary>
    /// <param name="dateTime">The UNIX date time in milliseconds</param>
    /// <returns>String.</returns>
    func convertToTimestamp(dateTime: Date) -> String
    {
        let theDouble = NSDate().timeIntervalSince1970
        
//        double theDouble = (TimeZoneInfo.ConvertTime(dateTime, TimeZoneInfo.Utc) - new DateTime(1970, 1, 1, 0, 0, 0, 0, System.DateTimeKind.Utc)).TotalSeconds;
//
//        theDouble = theDouble * 1000;
//        let theTimeString = String(describing: theDouble)
//        let commaIndex = theTimeString.index(of: ",")
//        let intValue = theTimeString.distance(from: theTimeString.startIndex, to: commaIndex!)
//
//        if (intValue <= 0)
//        {
//            return theTimeString;
//        }
        
        let intValue = Int(theDouble)
        
        return String(intValue)
    }
    
    func debug(log: String)
    {
        if (DEBUG)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
            
            ConsoleEmul.WriteLine(log: dateFormatter.string(from: Date()) + " " + log)
        }
    }
}

extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
}
