//
//  AceQLDataReader.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

class AceQLDataReader {
    static var DEBUG: Bool = false
    
    /// <summary>
    /// The instance that does all http stuff
    /// </summary>
    var aceQLHttpApi: AceQLHttpApi
    
    var traceOn: Bool = false
    
    var currentRowNum: Int = 0
    var rowsCount: Int
    
    var rowParser: RowParser? = nil
    var isClosed: Bool = false
    
    var valuesPerColIndex = [Int: Any]()
    var colTypesPerColIndex = [Int: String]()
    var colNamesPerColIndex = [Int: String]()
    var colIndexesPerColName = [String: Int]()
    
    var connection: AceQLConnection
    
    /// <summary>
    /// The JSON file containing the Result Set
    /// </summary>
    var file: URL?
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLDataReader"/> class.
    /// </summary>
    /// <param name="file">The JSON file containing the Result Set. Passed only for delete action.</param>
    /// <param name="readStream">The reading stream on file.</param>
    /// <param name="rowsCount">The number of rows in the file/result set.</param>
    /// <param name="connection">The AceQL connection.</param>
    /// <exception cref="System.ArgumentNullException">The file is null.</exception>
    init(file: URL?, jsonResult:[String: Any]?, rowsCount: Int, connection: AceQLConnection)
    {
        self.file = file
        self.rowsCount = rowsCount
        
        self.connection = connection
        self.aceQLHttpApi = connection.aceQLHttpApi
        
        rowParser = RowParser(jsonResult: jsonResult)
        self.rowsCount = rowsCount
    }
    
    
    /// <summary>
    /// Determines whether [is trace on].
    /// </summary>
    /// <returns><c>true</c> if [is trace on]; otherwise, <c>false</c>.</returns>
    func isTraceOn() -> Bool
    {
        return traceOn
    }
    
    /// <summary>
    /// Sets the trace on.
    /// </summary>
    /// <param name="traceOn">if set to <c>true</c> [trace on].</param>
    func etTraceOn(traceOn: Bool)
    {
        self.traceOn = traceOn
    }
    
    /// <summary>
    /// Traces this instance.
    /// </summary>
    func trace()
    {
        if (traceOn)
        {
            ConsoleEmul.WriteLine()
        }
    }
    
    /// <summary>
    /// Traces the specified string.
    /// </summary>
    /// <param name="s">The string to trace.</param>
    func trace(log: String)
    {
        if (traceOn)
        {
            print("")
        }
    }
    
    /// <summary>
    /// Advances the reader to the next record.
    /// Method is provided only for consistency: same method exists in SQLServer SqlDataReader class.
    /// <para/>
    /// It's cleaner to use <see cref="AceQLDataReader"/>.Read() because data are read from a <see cref="TextReader"/>
    /// (all data are already downloaded when <see cref="AceQLDataReader"/> is created.)
    /// </summary>
    /// <param name="cancellationToken">The cancellation instruction.</param>
    /// <returns>true if there are more rows; otherwise, false.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
//    public async Task<bool> ReadAsync(CancellationToken cancellationToken)
//{
//    Task<bool> task = new Task<bool>(Read);
//    task.Start();
//    return await task;
//    }
    
    /// <summary>
    /// Advances the reader to the next record.
    /// </summary>
    /// <returns>true if there are more rows; otherwise, false.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func read() ->Bool
    {
        testIsClosed()
        
        if (AceQLDataReader.DEBUG)
        {
            ConsoleEmul.WriteLine();
            ConsoleEmul.WriteLine(log: "currentRowNum: " + String(describing: currentRowNum));
            ConsoleEmul.WriteLine(log: "rowCount     : " + String(describing: rowsCount));
        }
        
        if (currentRowNum == rowsCount)
        {
            return false;
        }
        
        
        currentRowNum += 1
        rowParser?.buildRowNum(rowNum: currentRowNum);
        
        valuesPerColIndex = (rowParser?.getValuesPerColIndex()!)!
        colTypesPerColIndex = (rowParser?.getTypesPerColIndex()!)!
        colIndexesPerColName = (rowParser?.getColIndexesPerColName()!)!
        
        // Build first time the Dic of (colIndex, colName) from Dic (colName, colIndex)
        if (currentRowNum == 1)
        {
            for (key, value) in colIndexesPerColName
            {
                colNamesPerColIndex[value] = key
            }
        }
    
        
        return true;
    
    }
    
    /// <summary>
    /// Gets the value for  the specified name.
    /// </summary>
    /// <param name="name">The name.</param>
    /// <returns>The value.</returns>
    func getByName(name: String) -> Any? {
        testIsClosed();
        let colIndex = colIndexesPerColName[name];
        
        if (isDBNull(ordinal: colIndex!))
        {
            return nil
        }
        
        return valuesPerColIndex[colIndex!]
    }
    
    /// <summary>
    /// Gets the value for  the specified ordinal.
    /// </summary>
    /// <param name="ordinal">The ordinal.</param>
    /// <returns>The value.</returns>
    func getByInt(ordinal: Int) -> Any? {
        testIsClosed()
        
        if (isDBNull(ordinal: ordinal))
        {
            return nil
        }
        
        return valuesPerColIndex[ordinal]
    }
    
    /// <summary>
    /// Gets the number of columns in the current row.
    /// </summary>
    /// <value>The number of columns in the current row.</value>
    func fieldCount() -> Int {
        testIsClosed();
        return valuesPerColIndex.count
    }
    
    /// <summary>Gets a value that indicates whether the <see cref="AceQLDataReader"/> contains one or more rows.
    /// </summary>
    /// <value>true if the <see cref="AceQLDataReader"/> contains one or more rows; otherwise.</value>
    func hasRows() -> Bool {
        testIsClosed()
        return rowsCount > 0
    }
   
    
    
    /// <summary>
    /// Downloads the Blob and gets the stream.
    /// <para/>The cancellation token can be used to can be used to request that the operation be abandoned before the http request timeout.
    /// </summary>
    /// <param name="ordinal">The ordinal.</param>
    /// <param name="cancellationToken">The cancellation instruction.</param>
    /// <returns>The Stream to read the downloaded Blob.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
//    func getStreamAsync(ordinal: Int)
//    {
//        getStreamAsync(ordinal: ordinal)
//        try
//    {
//        // Global var avoids to propagate cancellationToken as parameter to all methods...
//        aceQLHttpApi.SetCancellationToken(cancellationToken);
//        return await GetStreamAsync(ordinal);
//        }
//        finally
//        {
//        aceQLHttpApi.ResetCancellationToken();
//        }
//    }
    /// <summary>
    /// Downloads the Blob and gets a reading <see cref="Stream"/>.
    /// </summary>
    /// <param name="ordinal">The ordinal.</param>
    /// <returns>The <see cref="Stream"/> to read the downloaded Blob.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func GetStreamAsync(ordinal: Int, completion: @escaping(Data?) -> Void)
    {
        if (isDBNull(ordinal: ordinal))
        {
//            return null;
        }
        
        testIsClosed();
        let blobId = getString(ordinal: ordinal);
        
        Debug(log: "");
        Debug(log: "blobId  : " + blobId!);
        
        aceQLHttpApi.blobDownloadAsync(blobId: blobId!) {data in
            completion(data)
        }
    }
    
    
    /// <summary>
    /// Gets the value of the specified column as a Boolean.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getBoolean(ordinal: Int) -> Bool
    {
        testIsClosed()
    
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
//            throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
    
        if (isDBNull(ordinal: ordinal))
        {
            return false;
        }
    
        return valuesPerColIndex[ordinal] as! Bool
    }
    
    
    ///// <summary>
    ///// Gets the byte.
    ///// </summary>
    ///// <param name="ordinal">The ordinal.</param>
    ///// <returns>System.Byte.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public byte GetByte(int ordinal)
    //{
    //    throw new NotSupportedException();
    //}
    
    ///// <summary>
    ///// Gets the bytes.
    ///// </summary>
    ///// <param name="ordinal">The ordinal.</param>
    ///// <param name="dataOffset">The data offset.</param>
    ///// <param name="buffer">The buffer.</param>
    ///// <param name="bufferOffset">The buffer offset.</param>
    ///// <param name="length">The length.</param>
    ///// <returns>System.Int64.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public long GetBytes(int ordinal, long dataOffset, byte[] buffer, int bufferOffset, int length)
    //{
    //    throw new NotSupportedException();
    //}
    
    ///// <summary>
    ///// Gets the character.
    ///// </summary>
    ///// <param name="ordinal">The ordinal.</param>
    ///// <returns>System.Char.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public char GetChar(int ordinal)
    //{
    //    throw new NotSupportedException();
    //}
    
    ///// <summary>
    ///// Gets the chars.
    ///// </summary>
    ///// <param name="ordinal">The ordinal.</param>
    ///// <param name="dataOffset">The data offset.</param>
    ///// <param name="buffer">The buffer.</param>
    ///// <param name="bufferOffset">The buffer offset.</param>
    ///// <param name="length">The length.</param>
    ///// <returns>System.Int64.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public long GetChars(int ordinal, long dataOffset, char[] buffer, int bufferOffset, int length)
    //{
    //    throw new NotSupportedException();
    //}
    
    ///// <summary>
    ///// Gets the name of the data type.
    ///// </summary>
    ///// <param name="ordinal">The ordinal.</param>
    ///// <returns>System.String.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public string GetDataTypeName(int ordinal)
    //{
    //    throw new NotSupportedException();
    //}
    
    /// <summary>
    /// Gets the value of the specified column as a <see cref="DateTime"/>.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getDateTime(ordinal: Int) -> Date
    {
        testIsClosed()
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
//        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        if (isDBNull(ordinal: ordinal))
        {
            return Date()
        }
        
        let theDateTime = valuesPerColIndex[ordinal] as! String
        let unixDate = Int64(theDateTime)
        let date = Date(timeIntervalSince1970: TimeInterval(unixDate!))
        return date
    }
    
    /// <summary>
    /// Gets the value of the specified column as a Decimal.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getDecimal(ordinal: Int) -> Decimal
    {
        testIsClosed()
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
//        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        if (isDBNull(ordinal: ordinal))
        {
            return 0;
        }
        
        return valuesPerColIndex[ordinal] as! Decimal
    }
    
    /// <summary>
    /// Gets the value of the specified column as a Double.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getDouble(ordinal: Int) -> Double
    {
        testIsClosed();
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
//        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        if (isDBNull(ordinal: ordinal))
        {
            return 0;
        }
        
        return valuesPerColIndex[ordinal] as! Double
    }
    
    ///// <summary>
    ///// Gets the enumerator.
    ///// </summary>
    ///// <returns>IEnumerator.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public IEnumerator GetEnumerator()
    //{
    //    throw new NotSupportedException();
    //}
    
    ///// <summary>
    ///// Gets the type of the field.
    ///// </summary>
    ///// <param name="ordinal">The ordinal.</param>
    ///// <returns>Type.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public Type GetFieldType(int ordinal)
    //{
    //    throw new NotSupportedException();
    //}
    
    /// <summary>
    /// Gets the value of the specified column as a float.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getFloat(ordinal: Int) -> Float
    {
        testIsClosed();
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
            //        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        if (isDBNull(ordinal: ordinal))
        {
            return 0;
        }
        
        return valuesPerColIndex[ordinal] as! Float
    }
    
    
    ///// <summary>
    ///// Gets the unique identifier. Not implemented.
    ///// </summary>
    ///// <param name="ordinal">The ordinal.</param>
    ///// <returns>Guid.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public Guid GetGuid(int ordinal)
    //{
    //    throw new NotSupportedException();
    //}
    
    /// <summary>
    /// Gets the value of the specified column as a 16-bit signed integer.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getInt16(ordinal: Int) -> Int16
    {
        testIsClosed();
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
            //        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        if (isDBNull(ordinal: ordinal))
        {
            return 0;
        }
        
        return valuesPerColIndex[ordinal] as! Int16
    }
    
    /// <summary>
    /// Gets the value of the specified column as a 32-bit signed integer.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getInt32(ordinal: Int) -> Int
    {
        testIsClosed();
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
            //        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        if (isDBNull(ordinal: ordinal))
        {
            return 0;
        }
        
        return Int(valuesPerColIndex[ordinal] as! String)!
    }
   
    
    /// <summary>
    /// Gets the value of the specified column as a 64-bit signed integer.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getInt64(ordinal: Int) -> Int64
    {
        testIsClosed();
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
            //        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        if (isDBNull(ordinal: ordinal))
        {
            return 0;
        }
        
        return valuesPerColIndex[ordinal] as! Int64
    }
    
    
    /// <summary>
    /// Gets the name of the specified column.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The name of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getName(ordinal: Int) -> String
    {
        testIsClosed();
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
            //        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        return valuesPerColIndex[ordinal] as! String
    }
    
    /// <summary>
    /// Gets the column ordinal, given the name of the column.
    /// </summary>
    /// <param name="name">The name of the column.</param>
    /// <returns>The zero-based column ordinal.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getOrdinal(name: String) -> Int
    {
        testIsClosed();
        
        if (!colIndexesPerColName.keys.contains(name))
        {
            //        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        return colIndexesPerColName[name]!
    }
    
    
    /// <summary>
    /// Gets the value of the specified column as a string.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getString(ordinal: Int) -> String?
    {
        testIsClosed();
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
//            throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        if (isDBNull(ordinal: ordinal))
        {
            return nil;
        }
        
        return valuesPerColIndex[ordinal] as? String
    }
    
    /// <summary>
    /// Gets the value of the specified column in its native format.
    /// </summary>
    /// <param name="ordinal">The zero-based column ordinal.</param>
    /// <returns>The value of the specified column.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func getValue(ordinal: Int) -> Any?
    {
        testIsClosed()
        
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
//            throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
        
        let colType = colTypesPerColIndex[ordinal]
        
        Debug(log: "");
        Debug(log: "ordinal: " + String(describing: ordinal));
        Debug(log: "colType: " + String(describing: colType));
        Debug(log: "value  : " + String(describing: valuesPerColIndex[ordinal]));
        
        if (AceQLTypes.isStringType(colType: colType!))
        {
            return valuesPerColIndex[ordinal]
        }
        else if (colType == AceQLTypes.BIT)
        {
            return getBoolean(ordinal: ordinal)
        }
        else if (AceQLTypes.isDateTimeType(colType: colType!))
        {
            return getDateTime(ordinal: ordinal)
        }
        else if (colType == AceQLTypes.SMALLINT || colType == AceQLTypes.TINYINT)
        {
            return getInt16(ordinal: ordinal)
        }
        else if (colType == AceQLTypes.DECIMAL || colType == AceQLTypes.NUMERIC)
        {
            return getDecimal(ordinal: ordinal)
        }
        else if (colType == AceQLTypes.INTEGER)
        {
            return getInt32(ordinal: ordinal)
        }
        else if (colType == AceQLTypes.REAL)
        {
            return getFloat(ordinal: ordinal)
        }
        else if (colType == AceQLTypes.FLOAT || colType == AceQLTypes.DOUBLE_PRECISION)
        {
            return getDouble(ordinal: ordinal)
        }
        else
        {
            if (isDBNull(ordinal: ordinal))
            {
                return nil
            }
        
        // If we don't know ==> just object, user will do the cast...
            return valuesPerColIndex[ordinal]
        }
    }
    
    ///// <summary>
    ///// Gets the values.
    ///// </summary>
    ///// <param name="values">The values.</param>
    ///// <returns>System.Int32.</returns>
    ///// <exception cref="System.NotSupportedException"></exception>
    //public int GetValues(object[] values)
    //{
    //    throw new NotSupportedException();
    //}
    
    
    /// <summary>
    ///  Gets a value that indicates whether the column contains non-existent or missing values.
    /// </summary>
    /// <param name="ordinal">The ordinal.</param>
    /// <returns>true if column contains non-existent or missing values, else false.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func isDBNull(ordinal: Int) -> Bool
    {
        testIsClosed();
    
        if (!valuesPerColIndex.keys.contains(ordinal))
        {
//        throw new AceQLException("No value found for ordinal: " + ordinal, 0, (Exception)null, (HttpStatusCode)200);
        }
    
        return (valuesPerColIndex[ordinal] == nil ? true : false)
    }
    
    func testIsClosed()
    {
        if (isClosed)
        {
//        throw new AceQLException("Instance is closed and disposed.", 0, (Exception)null, HttpStatusCode.OK);
        }
    }
    
    
    func Debug(log: String)
    {
        if (AceQLDataReader.DEBUG)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
            
            ConsoleEmul.WriteLine(log: dateFormatter.string(from: Date()) + " " + log)
        }
    }
}
