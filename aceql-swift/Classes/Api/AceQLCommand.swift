//
//  AceQLCommand.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

class AceQLCommand {
    /// <summary>
    /// The instance that does all http stuff
    /// </summary>
    var aceQLHttpApi: AceQLHttpApi?
    
    /// <summary>
    /// The text of the query.
    /// </summary>
    var cmdText: String = ""
    /// <summary>
    /// The AceQL connection
    /// </summary>
    var connection: AceQLConnection?
    
    /// <summary>
    /// The parameters
    /// </summary>
    var parameters: AceQLParameterCollection
    
    var prepare: Bool = false
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLCommand"/> class.
    /// </summary>
//    public AceQLCommand()
//{
//    }
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLCommand"/> class with the text of the query.
    /// </summary>
    /// <param name="cmdText">The text of the query.</param>
    /// <exception cref="System.ArgumentNullException">If cmdText is null.
    /// </exception>
    init (cmdText: String)
    {
        self.cmdText = cmdText
        parameters = AceQLParameterCollection(cmdText: cmdText)
    }
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLCommand"/> class with the text of the query
    /// and a <see cref="AceQLConnection"/>.
    /// </summary>
    /// <param name="cmdText">The text of the query.</param>
    /// <param name="connection">A <see cref="AceQLConnection"/> that represents the connection to a remote database.</param>
    /// <exception cref="System.ArgumentNullException">
    /// If cmdText is null
    /// or
    /// connection is null.
    /// </exception>
    convenience init (cmdText: String, connection: AceQLConnection)
    {
        self.init(cmdText: cmdText)
//        if (connection == null)
//        {
//        throw new ArgumentNullException("connection is null!");
//        }
//
        self.connection = connection
        self.aceQLHttpApi = connection.aceQLHttpApi
        
    }
    
    /// <summary>
    /// Sends the <see cref="AceQLCommand"/>.CommandText to the <see cref="AceQLConnection"/> and builds an <see cref="AceQLDataReader"/>.
    /// <para/>The cancellation token can be used to can be used to request that the operation be abandoned before the http request timeout.
    /// </summary>
    /// <param name="cancellationToken">The cancellation instruction.</param>
    /// <returns>An <see cref="AceQLDataReader"/>object.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func executeReaderAsync(completion:@escaping(AceQLDataReader?, StreamResultAnalyzer?)->Void)
    {
        // Statement wit parameters are always prepared statement
        if (parameters.count() == 0 && !prepare)
        {
            executeQueryAsStatementAsync() {result, streamResult in
                completion(result, streamResult)
            }
        }
        else
        {
            executeQueryAsPreparedStatementAsync() {result, streamResult in
                completion(result, streamResult)
            }
        }
    }
    
    /// <summary>
    ///  Sends the <see cref="AceQLCommand"/>.CommandText to the <see cref="AceQLConnection"/> and builds an <see cref="AceQLDataReader"/>.
    /// </summary>
    /// <returns>An <see cref="AceQLDataReader"/>object.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
//    func ExecuteReaderAsync() -> AceQLDataReader
//    {
//
//    }
    
    /// <summary>
    /// Creates a prepared version of the command. Optional call.
    /// Note that the remote statement will always be a prepared statement if
    /// the command contains parameters.
    /// </summary>
    func setPrepare()
    {
        self.prepare = true;
    }
    
    /// <summary>
    /// Executes the SQL statement against the connection and returns the number of rows affected.
    /// <para/>The cancellation token can be used to can be used to request that the operation be abandoned before the http request timeout.
    /// </summary>
    /// <param name="cancellationToken">The cancellation instruction.</param>
    /// <returns>The number of rows affected.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
//    func ExecuteNonQueryAsync() -> Int
//    {
//        return ExecuteNonQueryAsync();
//    }
    /// <summary>
    /// Executes the SQL statement against the connection and returns the number of rows affected.
    /// </summary>
    /// <returns>The number of rows affected.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func executeNonQueryAsync(completion:@escaping(Int, Bool)-> Void)
    {
        // Statement with parameters are always prepared statement
        if (parameters.count() == 0 && !prepare)
        {
            executeUpdateAsStatementAsync() {result, status in
                completion(result, status)
            }
        }
        else
        {
            return executeUpdateAsPreparedStatementAsync() {result, status in
                completion(result, status)
            }
        }
    }
    
    /// <summary>
    /// Executes the query as statement.
    /// <para/>The cancellation token can be used to can be used to request that the operation be abandoned before the http request timeout.
    /// </summary>
    /// <param name="cancellationToken">The cancellation instruction.</param>
    /// <returns>An <see cref="AceQLDataReader"/>object.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
//    func executeQueryAsStatementAsync() -> AceQLDataReader
//    {
//        // Global var avoids to propagate cancellationToken as parameter to all methods...
//        return executeQueryAsStatementAsync()
//    }
    
    /// <summary>
    /// Executes the query as statement.
    /// </summary>
    /// <returns>An <see cref="AceQLDataReader"/>object.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func executeQueryAsStatementAsync(completion: @escaping(AceQLDataReader?, StreamResultAnalyzer?) -> Void)
    {
        
        let isPreparedStatement = false
        let parametersMap: [String: String]? = nil
        
        aceQLHttpApi?.executeQueryAsync(cmdText: cmdText, isPreparedStatement: isPreparedStatement, statementParameters: parametersMap) { result, httpStatus in
            if (self.aceQLHttpApi?.gzipResult)! {
            } else {
            }
            
            if (result == nil)
            {
                completion(nil, nil)
                return;
            }
            
            let file = self.getUniqueResultSetFileAsync()
            
            let resultData = try? JSONSerialization.data(
                withJSONObject: result,
                options: [])
            let resultText = String(data: resultData!,
                                         encoding: .ascii)
            
            
            try? resultText!.write(to: file!, atomically: false, encoding: String.Encoding.utf8)
            
            let streamResult = StreamResultAnalyzer(jsonResult: result, httpStatusCode: httpStatus!)
            if (!streamResult.isStatusOkAsync()) {
                completion(nil, streamResult)
            }
            
            let rowCounter = RowCounter(jsonResult: result)
            let rowCount = rowCounter.countAsync()
            
            let aceQLDataReader = AceQLDataReader(file: file, jsonResult: result, rowsCount: rowCount, connection: self.connection!)
            completion(aceQLDataReader, nil)
        }
    }
    
    /// <summary>
    /// Generates a unique File on the system for the downloaded result set content.
    /// </summary>
    /// <returns>A unique File on the system.</returns>
    func getUniqueResultSetFileAsync() -> URL?
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let folderurl = GetFileUrl(path: Param.ACEQL_PCL_FOLDER)
            try? FileManager.default.createDirectory(at: folderurl!, withIntermediateDirectories: false, attributes: nil)
            
            let fileName = Param.ACEQL_PCL_FOLDER + "/" + UUID().uuidString + "-result-set.txt"
            return dir.appendingPathComponent(fileName)
        }
        return nil;
    }
    
    func GetFileUrl(path: String) -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return dir.appendingPathComponent(path)
        }
        return nil;
    }
    
    /// <summary>
    /// Executes the query as prepared statement.
    /// </summary>
    /// <returns>An <see cref="AceQLDataReader"/> object.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    func executeQueryAsPreparedStatementAsync(completion: @escaping(AceQLDataReader?, StreamResultAnalyzer?) -> Void)
    {
        let aceQLCommandUtil = AceQLCommandUtil(cmdText: cmdText, parameters: parameters)
        
        // Get the parameters and build the result set
        let statementParameters = aceQLCommandUtil.getPreparedStatementParameters()
        
        // Replace all @parms with ? in sql command
        cmdText = aceQLCommandUtil.replaceParmsWithQuestionMarks()
        
        
        
        let isPreparedStatement = true
        
        aceQLHttpApi?.executeQueryAsync(cmdText: cmdText, isPreparedStatement: isPreparedStatement, statementParameters: statementParameters){ result, httpStatus in
            
            if (self.aceQLHttpApi!.gzipResult) {
            } else {
            }
            
            if (result == nil) {
                completion(nil, nil)
                return;
            }
            let file = self.getUniqueResultSetFileAsync()
            
            let resultData = try? JSONSerialization.data(
                withJSONObject: result,
                options: [])
            let resultText = String(data: resultData!,
                                    encoding: .ascii)
            
            try? resultText!.write(to: file!, atomically: false, encoding: String.Encoding.utf8)
            
            let streamResult = StreamResultAnalyzer(jsonResult: result, httpStatusCode: httpStatus!)
            if (!streamResult.isStatusOkAsync()) {
                completion(nil, streamResult)
            }
            
            let rowCounter = RowCounter(jsonResult: result)
            let rowCount = rowCounter.countAsync()
            
            let aceQLDataReader = AceQLDataReader(file: file, jsonResult: result, rowsCount: rowCount, connection: self.connection!)
            completion(aceQLDataReader, streamResult)
        }
        
    }
    
    
    /// <summary>
    /// Executes the update as prepared statement.
    /// </summary>
    /// <returns>System.Int32.</returns>
    /// <exception cref="AceQLException">
    /// </exception>
    func executeUpdateAsPreparedStatementAsync(completion: @escaping(Int, Bool)->Void)
    {
        let aceQLCommandUtil = AceQLCommandUtil(cmdText: cmdText, parameters: parameters)

        let statementParameters = aceQLCommandUtil.getPreparedStatementParameters()
        
        // Uploads Blobs
        var blobIds = aceQLCommandUtil.blobIds
        var blobStreams = aceQLCommandUtil.blobStreams
        var blobLengths = aceQLCommandUtil.blobLengths

        var totalLength: Int64 = 0;
        if (blobIds.count > 0 ) {
            for i in 0...blobIds.count - 1
            {
                totalLength += blobLengths[i]
            }
            
            for i in 0...blobIds.count - 1
            {
                aceQLHttpApi?.blobUploadAsync(blobId: blobIds[i], stream: blobStreams[i], totalLength: totalLength) {result in
                    self.executeUpdate(aceQLCommandUtil: aceQLCommandUtil, statementParameters: statementParameters) {result, status in
                        completion(result, status)
                    }
                }
            }
        } else {
            self.executeUpdate(aceQLCommandUtil: aceQLCommandUtil, statementParameters: statementParameters) {result, status in
                completion(result, status)
                
            }
        }
        
    }
    
    func executeUpdate(aceQLCommandUtil: AceQLCommandUtil, statementParameters: [String: String], completion: @escaping(Int, Bool) -> Void) {
        // Get the parameters and build the result set
        
        
        // Replace all @parms with ? in sql command
        cmdText = aceQLCommandUtil.replaceParmsWithQuestionMarks();
        
        var parametersMap = [ "sql": cmdText, "prepared_statement": "true"]
        
        //statementParameters.ToList().ForEach(x => parametersMap.Add(x.Key, x.Value));
        let keyList = statementParameters.keys
        for key in keyList
        {
            parametersMap[key] = statementParameters[key]
        }
        
        let isPreparedStatement = true;
        
        aceQLHttpApi?.executeUpdateAsync(sql: cmdText, isPreparedStatement: isPreparedStatement, statementParameters: statementParameters) { result, status in
            completion(result, status)
        }
    }
    
    
    /// <summary>
    /// Executes the update as statement.
    /// </summary>
    /// <returns>System.Int32.</returns>
    /// <exception cref="AceQLException">
    /// </exception>
    func executeUpdateAsStatementAsync(completion: @escaping(Int, Bool) -> Void)
    {
        let isPreparedStatement: Bool = false
        let statementParameters: [String: String]? = nil
        aceQLHttpApi?.executeUpdateAsync(sql: cmdText, isPreparedStatement: isPreparedStatement, statementParameters: statementParameters) {result, status in
            completion(result, status)
        }
    }
    
    
    
    /// <summary>
    /// Gets ot set SQL statement to execute against a remote SQL database.
    /// </summary>
    /// <value>The SQL statement to execute against a remote SQL database.</value>
    
    
    func getCommandText() -> String {
        return cmdText
    }

    func setCommandText(value: String) {
        self.cmdText = value
    }
    
    
    /// <summary>
    /// Gets or sets the <see cref="AceQLConnection"/> used by this instance of <see cref="AceQLCommand"/>.
    /// </summary>
    /// <value>The remote database connection.</value>
    
    func getConnection() -> AceQLConnection {
        return connection!
    }
    
    func setConnection(value: AceQLConnection) {
        self.connection = value
        self.aceQLHttpApi = connection!.aceQLHttpApi
    }
}
