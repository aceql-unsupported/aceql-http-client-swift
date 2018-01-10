//
//  AceQLConnection.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

public class AceQLConnection {
    var DEBUG: Bool = false
    
    var aceQLHttpApi: AceQLHttpApi
    var connectionOpened: Bool = false
    
    /// <summary>
    ///  Says if connection is closed
    /// </summary>
    var closeAsyncDone: Bool = false
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLConnection"/> class.
    /// </summary>
    public init()
    {
        aceQLHttpApi = AceQLHttpApi()
    }
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLConnection"/> class  when given a string that contains the connection string.
    /// </summary>
    /// <param name="connectionString">The connection used to open the remote database.</param>
    /// <exception cref="System.ArgumentNullException">If connectionString is null.</exception>
    public init (connectionString: String)
    {
        aceQLHttpApi = AceQLHttpApi(connectionString: connectionString)
    }
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLConnection"/> class  when given a string that contains the connection string
    /// and an <see cref="AceQLCredential"/> object that contains the username and password.
    /// </summary>
    /// <param name="connectionString">A connection string that does not use any of the following connection string keywords: Username
    /// or Password.</param>
    /// <param name="credential"><see cref="AceQLCredential"/> object. </param>
    /// <exception cref="System.ArgumentNullException">If connectionString is null or <see cref="AceQLCredential"/> is null.</exception>
    /// <exception cref="System.ArgumentException">connectionString token does not contain a = separator: " + line</exception>
    public init(connectionString: String, credential: AceQLCredential)
    {
        aceQLHttpApi = AceQLHttpApi(connectionString: connectionString, credential: credential)
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLConnection"/> class.
    /// </summary>
    public init(server: String, database: String, username: String, password: String)
    {
        let connectionString = "Server=\(server); Database=\(database); "
        let credential = AceQLCredential(username: username, password: password)
        aceQLHttpApi = AceQLHttpApi(connectionString: connectionString, credential: credential)
    }

    /// <summary>
    /// Gets the path to the local AceQL folder where SQL queries results are stored.
    /// </summary>
    /// <returns>The path to the local AceQL folder.</returns>
    public static func getAceQLLocalFolderAsync() -> URL?
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return dir.appendingPathComponent(Param.TRACE_TXT)
        }
        return nil;
    }
    
    
    /// <summary>
    /// Traces this instance.
    /// </summary>
    public func traceAsync()
    {
        AceQLHttpApi.traceAsync()
    }
    
    /// <summary>
    /// Traces the specified string.
    /// </summary>
    /// <param name="s">The string to trace</param>
    public func traceAsync(log: String)
    {
        AceQLHttpApi.traceAsync(contents: log)
    }
    
    /// <summary>
    /// Opens a connection with the remote database.
    /// </summary>
    /// <exception cref="AceQLException">If any Exception occurs.</exception>
    public func openAsync(completion: @escaping(Bool) -> Void)
    {
        self.connectionOpened = true
        aceQLHttpApi.openAsync() {status in
            completion(status)
        }
    }

    /// <summary>
    /// Change IsolationLevel with the specified isolation level.
    /// </summary>
    /// <param name="isolationLevel">The isolation level.</param>
    public func changeIsolationLevel(isolationLevel: IsolationLevel)
    {
        let isolationLevelStr = getIsolationAsString(isolationLevel: isolationLevel)
        aceQLHttpApi.callApiNoResultAsync(commandName: "set_transaction_isolation_level", commandOption: isolationLevelStr){status in}
    }
    
    /// <summary>
    /// Closes the connection to the remote database and closes the http session.
    /// This is the preferred method of closing any open connection.
    /// </summary>
    public func closeAsync()
    {
        if (closeAsyncDone)
        {
            return;
        }
    
        aceQLHttpApi.callApiNoResultAsync(commandName: "disconnect", commandOption: ""){status in}
        closeAsyncDone = true;
    }
    
    public func run(sql: String, completion: @escaping(String?, Bool) -> Void)
    {
        var command: AceQLCommand? = nil
        command = AceQLCommand(cmdText: sql, connection: self)
        
        command?.executeNonQueryAsync() { result, status in
            print(result.description)
            if (!status)
            {
                self.rollbackAsync() { success in }
            }
            
            completion(result.description, status)
        }
    }
    
    public func run(sql: String, completion: @escaping([Array<Any>]) -> Void)
    {
        var command: AceQLCommand? = nil
        command = AceQLCommand(cmdText: sql, connection: self)
        
        command?.executeReaderAsync(completion: { (dataReader, exception) in
            var data = [Array<Any>] ()
            if (dataReader != nil)
            {
                if (exception == nil || exception?.isStatusOkAsync() == true)
                {
                    var iRow: Int = 0
                    while (dataReader?.read())! {
                        var rowData = Array<Any>()
                        let columnData = dataReader?.valuesPerColIndex
                        
                        columnData?.forEach({ (arg) in
                            rowData.append(arg.value)
                        })

                        
                        iRow = iRow + 1
                        data.append(rowData)
                    }
                }
            }
            
            completion(data)
        })
    }
    
    public func prepare(sql: String) -> AceQLStatement?
    {
        let stmt = AceQLStatement(connection: self, sql: sql)
        return stmt
    }
    
    public func downloadBlob(blobId: String?, completion: @escaping(Data?) -> Void)
    {
        aceQLHttpApi.blobDownloadAsync(blobId: blobId!) { data in
            completion(data)
        }
    }
    
    /// <summary>
    /// Says if trace is on. If on, a trace is done on the file "trace.txt" in the path of value AceQL.Client.Api.GetAceQLLocalFolderAsync().
    /// </summary>
    /// <returns>true if trace is on, else false.</returns>
    public static func isTraceOn() -> Bool
    {
        return AceQLHttpApi.isTraceOn()
    }
    
    /// <summary>
    /// Sets the trace on/off. If on, a trace is done on the file "trace.txt" in the path of value AceQL.Client.Api.GetAceQLLocalFolderAsync().
    /// </summary>
    /// <param name="traceOn">If true, trace will be on; else trace will be off.</param>
    public static func setTraceOn(traceOn: Bool)
    {
        AceQLHttpApi.setTraceOn(traceOn: traceOn);
    }
    
    
    /// <summary>
    /// Returns the progress indicator variable that will store Blob/Clob upload progress between 0 and 100.
    /// </summary>
    /// <returns>The progress indicator variable that will store Blob/Clob upload progress between 0 and 100.</returns>
    public func getProgressIndicator() -> AceQLProgressIndicator
    {
        return aceQLHttpApi.getProgressIndicator()
    }
    
    /// <summary>
    /// Sets the progress indicator variable that will store Blob/Clob upload progress between 0 and 100.
    /// </summary>
    /// <param name="progressIndicator">The progress indicator variable that will store Blob/Clob upload progress between 0 and 100.</param>
    public func setProgressIndicator(progressIndicator: AceQLProgressIndicator)
    {
        aceQLHttpApi.setProgressIndicator(progressIndicator: progressIndicator);
    }
    
    /// <summary>
    /// Returns the AceQL Client SDK current Version.
    /// </summary>
    /// <returns>the AceQL SDK current Version.</returns>
    public func getClientVersion() -> String
    {
        return Version.GetVersion();
    }
    
    /// <summary>
    /// Returns the remote AceQL HTTP Server Version.
    /// </summary>
    /// <returns>the remote  AceQL Server Version.</returns>
    /// <exception cref="AceQL.Client.Api.AceQLException">If any Exception occurs.</exception>
    public func getServerVersionAsync(completion: @escaping(String?, Bool) -> Void)
    {
        aceQLHttpApi.callApiWithResultAsync(commandName: "get_version", commandOption: "") {serverVersion, status in
            completion(serverVersion, status)
        }
        
    }
    
    /// <summary>
    /// Gets or sets the connection string used to connect to the remote database.
    /// </summary>
    /// <value>The connection string used to connect to the remote database.</value>
    public func getConnectionString() -> String {
        return aceQLHttpApi.connectionString
    }
    
    public func setConnectionString(value: String) {
        aceQLHttpApi.connectionString = value
    }
    
    /// <summary>
    /// Gets the current database in use.
    /// </summary>
    /// <value>The current database in use.</value>
    
    public func getDatabaseString() -> String {
        return aceQLHttpApi.database!
    }
    
    
    /// <summary>
    /// Gets a value indicating whether [pretty printing] is on or off. Defaults to false.
    /// </summary>
    /// <value><c>true</c> if [pretty printing]; otherwise, <c>false</c>.</value>
    
    func getPrettyPrinting() -> Bool {
        return aceQLHttpApi.prettyPrinting
    }
    
    func setPrettyPrinting(value: Bool) {
        aceQLHttpApi.prettyPrinting = value
    }
    
    /// <summary>
    /// Gets or sets a value indicating whether SQL result sets are returned compressed with the GZIP file format
    /// before download. Defaults to true.
    /// </summary>
    /// <value>True if SQL result sets are returned compressed with the GZIP file format
    /// before download.</value>
    
    func getGzipResult() -> Bool {
        return aceQLHttpApi.gzipResult
    }
    
    func setGzipResult(value: Bool) {
        aceQLHttpApi.gzipResult = value
    }
    
    /// <summary>
    /// Gets the time to wait in milliseconds while trying to establish a connection before terminating the attempt and generating an error.
    /// If value is 0, <see cref="System.Net.Http.HttpClient"/> default will value be used.
    /// </summary>
    
    func getConnectionTimeout() -> Int {
        return aceQLHttpApi.timeout
    }
    
    
    
    /// <summary>
    /// Gets or sets the <see cref="AceQLCredential"/> object for this connection.
    /// </summary>
    /// <value>The <see cref="AceQLCredential"/> object for this connection.</value>
    func getCredential() -> AceQLCredential {
        return aceQLHttpApi.credential!
    }
    
    func setCredential(value: AceQLCredential) {
        aceQLHttpApi.credential = value
    }
    
    
    ///// <summary>
    ///// Creates a new object that is a copy of the current instance.
    ///// </summary>
    ///// <returns>A new object that is a copy of this instance.</returns>
    //public object Clone()
    //{
    //    return new AceQLConnection(ConnectionString);
    //}
    
    func debug(log: String)
    {
        if (DEBUG)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
            
            ConsoleEmul.WriteLine(log: dateFormatter.string(from: Date()) + " " + log)
        }
    }
    
    public func rollbackAsync(completion: @escaping(Bool) -> Void)
    {
        aceQLHttpApi.callApiNoResultAsync(commandName: "rollback", commandOption: ""){status in
            completion(status)
        }
    }
    
    public func commitAsync(completion: @escaping(Bool) -> Void)
    {
        aceQLHttpApi.callApiNoResultAsync(commandName: "commit", commandOption: ""){status in
            completion(status)
        }
    }
    
    public func setAutoCommitAsync(value: Bool, completion: @escaping(Bool) -> Void)
    {
        aceQLHttpApi.callApiNoResultAsync(commandName: "set_auto_commit", commandOption: value ? "true" : "false"){status in
            completion(status)
        }
    }
    
    /// <summary>
    /// Gets the isolation as string.
    /// </summary>
    /// <param name="isolationLevel">The isolation level.</param>
    /// <returns>Isolation as string.</returns>
    public func getIsolationAsString(isolationLevel: IsolationLevel) -> String
    {
        if (isolationLevel == IsolationLevel.Unspecified)
        {
            return "NONE"
        }
        else if (isolationLevel == IsolationLevel.ReadCommitted)
        {
            return "READ_COMMITTED"
        }
        else if (isolationLevel == IsolationLevel.ReadUncommitted)
        {
            return "READ_UNCOMMITTED"
        }
        else if (isolationLevel == IsolationLevel.RepeatableRead)
        {
            return "REPEATABLE_READ"
        }
        else if (isolationLevel == IsolationLevel.Serializable)
        {
            return "SERIALIZABLE"
        }
        else {
            return "UNKNOWN"
        }
    }
}
