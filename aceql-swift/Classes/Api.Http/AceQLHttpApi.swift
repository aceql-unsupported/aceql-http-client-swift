//
//  AceQLHttpApi.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

class AceQLHttpApi: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    let ESCAPED_SEMICOLON_WORD = "\\semicolon"
    let ESCAPED_SEMICOLON = "\\;"
    
    let DEBUG = false
    
    /// <summary>
    /// The server URL
    /// </summary>
    var server: String? = nil
    
    /// <summary>
    /// The database
    /// </summary>
    var database: String? = nil
    
    /// <summary>
    /// Says if session is stateless. defaults to false.
    /// </summary>
    var stateless = false
    
    /// <summary>
    /// The Proxy Uri, if we don't want
    /// </summary>
    var proxyUri: String? = nil
    
    /// <summary>
    /// The timeout in milliseconds
    /// </summary>
    var timeout: Int = 0;
    
    /// <summary>
    /// The HTTP status code
    /// </summary>
    var httpStatusCode: HTTPURLResponse?
    
    // Future usage
    //int connectTimeout = 0;
    
    /// <summary>
    /// The pretty printing
    /// </summary>
    var prettyPrinting = false
    /// <summary>
    /// The gzip result
    /// </summary>
    var gzipResult = false
    
    /// <summary>
    /// The trace on
    /// </summary>
    static var TRACE_ON = false
    /// <summary>
    /// The URL
    /// </summary>
    var url: String = ""
    
    var connectionString: String = ""
    
    var progressIndicator = AceQLProgressIndicator()
    var credential: AceQLCredential?
    
    var useCancellationToken = false
    
    var userName: String?
    var password: String?
    
    var theUrl: String = ""
    
    override init() {
        
    }
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLHttpApi"/> class.
    /// </summary>
    /// <param name="connectionString">The connection string.
    /// </param>"
    /// <exception cref="System.ArgumentException">connectionString token does not contain a = separator: " + line</exception>
    init(connectionString: String)
    {
        self.connectionString = connectionString;
    }
    
    
    convenience init (connectionString: String, credential: AceQLCredential)
    {
        self.init(connectionString: connectionString)
        self.credential = credential
    }
    
    
    /// <summary>
    /// Opens this instance.
    /// </summary>
    /// <exception cref="ArgumentNullException"> if a required parameter extracted from connection string is missing.
    /// </exception>
    /// <exception cref="AceQLException"> if any other Exception occurs.
    /// </exception>
    func openAsync(completion: @escaping(Bool) -> Void)
    {
        decodeConnectionString()
    
        var username: String?
        var password: String?
    
        username = self.credential?.username
        password = self.credential?.password
        
    
        if (server == nil)
        {
//            throw AceQLException.missedServer
            completion(false)
            return;
        }
        if (username == nil)
        {
//            throw AceQLException.missedUsername
            completion(false)
            return;
        }
        if (password == nil)
        {
//            throw AceQLException.missedPassword
            completion(false)
            return;
        }
        if (database == nil)
        {
//            throw AceQLException.missedDatabase
            completion(false)
            return;
        }
    
        theUrl = server! + "/database/" + database! + "/username/" + username!
        theUrl = theUrl + "/connect" + "?password=" + password! + "&stateless=" + String(describing: stateless)
        ConsoleEmul.WriteLine(log: "theUrl: " + theUrl)
    
        callWithGetAsync(url: theUrl) {result, status in
            if result == nil {
                completion(false)
            } else {
                let resultAnalyzer = ResultAnalyzer(jsonResult: result, httpStatusCode: status!)
    //            if (!resultAnalyzer.isStatusOk()) {
    //                throw new AceQLException(resultAnalyzer.GetErrorMessage(),
    //                                         resultAnalyzer.GetErrorId(),
    //                                         resultAnalyzer.GetStackTrace(),
    //                                         httpStatusCode);
    //            }
                
                let theSessionId = resultAnalyzer.getValue(name: "session_id");
                self.url = self.server! + "/session/" + theSessionId! + "/";
                AceQLHttpApi.traceAsync(contents: "OpenAsync url: " + self.url)
                completion(resultAnalyzer.isStatusOk())
            }
        }
    }
    
    
    /// <summary>
    /// Traces this instance.
    /// </summary>
    static func traceAsync()
    {
        traceAsync(contents: "")
    }
    
    /// <summary>
    /// Traces the specified string.
    /// </summary>
    /// <param name="contents">The string to trace</param>
    static func traceAsync(contents: String)
    {
        if (TRACE_ON)
        {
            let file = AceQLCommandUtil.getTraceFileAsync()
            try? contents.write(to: file!, atomically: false, encoding: String.Encoding.utf8)
        }
    }
    
    
    /// <summary>
    /// Decode connection string and load elements in memory.
    /// </summary>
    func decodeConnectionString()
    {
        // Replace escaped "\;"
        connectionString = connectionString.replacingOccurrences(of: ESCAPED_SEMICOLON, with: ESCAPED_SEMICOLON_WORD)
        
        var theServer: String? = nil
        var theDatabase: String? = nil
        var theUsername: String? = nil
        var thePassword: String? = nil
        var theStateless = false
        var theProxyUri: String? = nil
        
        var isNTLM = false
        var theTimeout: Int = 0;
        let lines = connectionString.split(separator: ";")
        
        var proxyUsername: String? = nil
        var proxyPassword: String? = nil
        
        for line in lines
        {
        // If some empty ;
            if (line.trimmingCharacters(in: .whitespaces).count <= 2)
            {
                continue;
            }
            
            var theLines = line.split(separator: "=")
            
            if (theLines.count != 2)
            {
                
//            throw new ArgumentException("connectionString token does not contain a = separator: " + line);
            }
        
            let property = theLines[0].trimmingCharacters(in: .whitespaces)
            var value = theLines[1].trimmingCharacters(in: .whitespaces)
            
            if (property.lowercased() == "server")
            {
                theServer = value;
            }
            else if (property.lowercased() == "database")
            {
                theDatabase = value;
            }
            else if (property.lowercased() == "username")
            {
                value = value.replacingOccurrences(of: "\\semicolon", with: ";")
                theUsername = value;
            }
            else if (property.lowercased() == "password")
            {
                value = value.replacingOccurrences(of: "\\semicolon", with: ";")
                thePassword = value
            }
            else if (property.lowercased() == "stateless")
            {
                if (value.lowercased() == "true")
                {
                    theStateless = true
                } else {
                    theStateless = false
                }
                
            }
            else if (property.lowercased() == "ntlm")
            {
                if (value.lowercased() == "true")
                {
                    isNTLM = true
                } else {
                    isNTLM = false
                }
                
            }
            else if (property.lowercased() == "proxyuri")
            {
                theProxyUri = value;
                // Set to null a "null" string
                if (theProxyUri!.lowercased() == "null" || theProxyUri!.count == 0)
                {
                    theProxyUri = nil
                }
                ConsoleEmul.WriteLine(log: "theProxyUri:" + theProxyUri! + ":");
            }
            else if (property.lowercased() == "proxyusername")
            {
                value = value.replacingOccurrences(of: ESCAPED_SEMICOLON_WORD, with: ";")
                proxyUsername = value
            
                // Set to null a "null" string
                if (proxyUsername!.lowercased() == "null" || proxyUsername!.count == 0)
                {
                    proxyUsername = nil
                }
                
                }
                else if (property.lowercased() == "proxypassword")
                {
                    value = value.replacingOccurrences(of: "\\semicolon", with: ";")
                    proxyPassword = value;
                
                // Set to null a "null" string
                if (proxyPassword!.lowercased() == "null" || proxyPassword!.count == 0)
                {
                    proxyPassword = nil
                }
                }
                else if (property.lowercased() == "timeout")
                {
                    theTimeout = Int(value)!
                }
            }
        
        
        debug(log: "connectionString   : " + connectionString);
        
        if (proxyUri != nil) {
            debug(log: "theProxyUri        : " + String(describing: theProxyUri!));
        }
        
        if (proxyUsername != nil) {
            debug(log: "theProxyCredentials: " + String(describing: proxyUsername!) + " / " + String(describing: proxyPassword!));
        }
    
        theUsername = self.userName
        thePassword = self.password
        
    //        if (isNTLM)
    //        {
    //        theProxyCredentials = CredentialCache.DefaultCredentials;
    //        }
    //        else
    //        {
    //        if (proxyUsername != null && proxyPassword != null)
    //        {
    //        theProxyCredentials = new NetworkCredential(proxyUsername, proxyPassword);
    //        }
        
        initServer(server: theServer, database: theDatabase, username: theUsername, password: thePassword, stateless: theStateless, proxyUri: theProxyUri, timeout: theTimeout)
    
    }
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLConnection"/> class.
    /// </summary>
    /// <param name="server">The server URL.</param>
    /// <param name="database">The database.</param>
    /// <param name="username">The username.</param>
    /// <param name="password">The password.</param>
    /// <param name="stateless">The stateless.</param>
    /// <param name="proxyUri">The Proxy Uri.</param>
    /// <param name="proxyCredentials">The credentials.</param>
    /// <param name="timeout">The timeout.</param>
    /// <exception cref="System.ArgumentNullException">
    /// server is null!
    /// or
    /// username is null!
    /// or
    /// password is null!
    /// or
    /// database is null!
    /// </exception>
    
    func initServer(server: String?, database:String?, username: String?, password: String?, stateless: Bool, proxyUri: String?, timeout: Int)
    {
        self.server = server
        self.database = database
        
//        if (username != null && password != null && credential == null)
//        {
//        this.credential = new AceQLCredential(username, password);
//        }
        
        self.stateless = stateless
        self.proxyUri = proxyUri
        self.userName = username
        self.password = password
        self.timeout = timeout
    }
    
    
    /// <summary>
    /// Build an HttpClient instance with proxy settings, if necessary. Proxy used is System.Net.WebRequest.DefaultWebProxy
    /// </summary>
    /// <param name="proxyUri"></param>
    /// <param name="credentials">The credentials to use for an authenticated proxy. null if none.</param>
    /// <returns>The HtpClientHandler.</returns>
//    internal static HttpClientHandler BuildHttpClientHandler(string proxyUri, ICredentials credentials)
//{
//    Proxy proxy = null;
//    // Used to test if have Proxy defined in IE
//    String proxyUriToUse = null;
//
//    // Test if used the default Web Proxy or the one passed in connection string:
//    if (proxyUri == null)
//    {
//    proxyUriToUse = System.Net.WebRequest.DefaultWebProxy.GetProxy(new Uri("http://www.google.com")).ToString();
//    }
//    else
//    {
//    proxy = new Proxy(proxyUri);
//    proxyUriToUse = proxy.GetProxy(new Uri("http://www.google.com")).ToString();
//    }
//
//    Debug("uriProxy: " + proxyUriToUse);
//
//    if (credentials != null && credentials.GetType() == typeof(NetworkCredential))
//    {
//    Debug("credentials: " + ((NetworkCredential)credentials).UserName + "/" + ((NetworkCredential)credentials).Password);
//    }
//
//    if (proxyUriToUse.Contains("http://www.google.com"))
//    {
//    Debug("System.Net.WebRequest.DefaultWebProxy is default");
//    HttpClientHandler handler = new HttpClientHandler();
//    return handler;
//    }
//    else
//    {
//    HttpClientHandler httpClientHandler = new HttpClientHandler()
//    {
//    UseProxy = true,
//    UseDefaultCredentials = false
//    };
//
//    if (proxy == null)
//    {
//    httpClientHandler.Proxy = System.Net.WebRequest.DefaultWebProxy;
//    }
//    else
//    {
//    httpClientHandler.Proxy = proxy;
//    }
//
//    httpClientHandler.Proxy.Credentials = credentials;
//    httpClientHandler.PreAuthenticate = true;
//    return httpClientHandler;
//    }
//
//    }
//
    /// <summary>
    /// Calls the with get return stream.
    /// </summary>
    /// <param name="url">The URL.</param>
    /// <returns>Stream.</returns>
    func callWithGetReturnStreamAsync(url: String, completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void)
    {
        let config = URLSessionConfiguration.default
        
        if (self.proxyUri != nil) {
            var proxyConfiguration = [NSObject: AnyObject]()
            proxyConfiguration[kCFNetworkProxiesHTTPEnable] = true as AnyObject
            proxyConfiguration[kCFProxyUsernameKey] = self.userName! as AnyObject
            proxyConfiguration[kCFProxyPasswordKey] = self.password! as AnyObject
            proxyConfiguration[kCFNetworkProxiesHTTPProxy] = self.proxyUri! as AnyObject
            config.connectionProxyDictionary = proxyConfiguration
        }
        
        let session = URLSession(configuration: config)
        
        let url: URL? = URL(string: url)
        
        _ = session.dataTask(with: url!) {
            data, response, error in
                guard error == nil else {
                    print(error!)
                    completion(nil, response as? HTTPURLResponse)
                    return
                }
            
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                    completion(nil, response as? HTTPURLResponse)
                    return
                }
            
                guard let data = data else {
                    print("Data is empty")
                    completion(nil, response as? HTTPURLResponse)
                    return
                }
            
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
                if (json == nil)
                {
                    
                    completion(nil, response as? HTTPURLResponse)
                    return
                }
            
            
            
            completion(json!, response as? HTTPURLResponse)
            
            }.resume()
    }
    
    func blobDownload(url: String, completion: @escaping (Data?, HTTPURLResponse?) -> Void)
    {
        let config = URLSessionConfiguration.default
        
        if (self.proxyUri != nil) {
            var proxyConfiguration = [NSObject: AnyObject]()
            proxyConfiguration[kCFNetworkProxiesHTTPEnable] = true as AnyObject
            proxyConfiguration[kCFProxyUsernameKey] = self.userName! as AnyObject
            proxyConfiguration[kCFProxyPasswordKey] = self.password! as AnyObject
            proxyConfiguration[kCFNetworkProxiesHTTPProxy] = self.proxyUri! as AnyObject
            config.connectionProxyDictionary = proxyConfiguration
        }
        
        let session = URLSession(configuration: config)
        
        let url: URL? = URL(string: url)
        
        _ = session.dataTask(with: url!) {
            data, response, error in
            guard error == nil else {
                print(error!)
                completion(nil, response as? HTTPURLResponse)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                completion(nil, response as? HTTPURLResponse)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                completion(nil, response as? HTTPURLResponse)
                return
            }
            
            completion(data, response as? HTTPURLResponse)
            }.resume()
    }
    
    
    /// <summary>
    /// Executes a POST with parameters.
    /// </summary>
    /// <param name="action">The action.</param>
    /// <param name="parameters">The request parameters.</param>
    /// <returns>Stream.</returns>
    /// <exception cref="System.ArgumentNullException">
    /// action is null!
    /// or
    /// postParameters is null!
    /// </exception>
    func callWithPostAsync(action: String, parameters:[String: String], completion: @escaping ([String: Any]?, HTTPURLResponse?)-> Void)
    {
        let url = URL(string: self.url + action)!
        let config = URLSessionConfiguration.default
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        
        var components = URLComponents()
        components.queryItems = parameters.map {
            URLQueryItem(name: $0, value: $1)
        }
        var postString = components.url!.absoluteString
        let index1 = postString.index(postString.startIndex, offsetBy: 1)
        postString = postString.substring(from: index1)
        
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession(configuration: config)
        if (self.proxyUri != nil) {
            var proxyConfiguration = [NSObject: AnyObject]()
            proxyConfiguration[kCFNetworkProxiesHTTPEnable] = true as AnyObject
            proxyConfiguration[kCFProxyUsernameKey] = self.userName! as AnyObject
            proxyConfiguration[kCFProxyPasswordKey] = self.password! as AnyObject
            proxyConfiguration[kCFNetworkProxiesHTTPProxy] = self.proxyUri! as AnyObject
            config.connectionProxyDictionary = proxyConfiguration
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                completion(nil, response as? HTTPURLResponse)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                completion(nil, response as? HTTPURLResponse)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if (json == nil)
            {
                completion(nil, response as? HTTPURLResponse)
                return
            }
            completion(json!, response as? HTTPURLResponse)
            
        }
        
        
        task.resume()
    }
    
    /// <summary>
    /// Calls the API no result.
    /// </summary>
    /// <param name="commandName">Name of the command.</param>
    /// <param name="commandOption">The command option.</param>
    /// <exception cref="System.ArgumentNullException">commandName is null!</exception>
    /// <exception cref="AceQLException">
    /// HTTP_FAILURE" + " " + httpStatusDescription - 0
    /// or
    /// or
    /// 0
    /// </exception>
    func callApiNoResultAsync(commandName: String, commandOption: String, completion: @escaping(Bool) -> Void)
    {
        callWithGetAsync(action: commandName, actionParameter: commandOption) { result, status in
            let resultAnalyzer = ResultAnalyzer(jsonResult: result, httpStatusCode: status)
//                throw AceQLException(resultAnalyzer.getErrorMessage(),
//                                         resultAnalyzer.getErrorId(),
//                                         resultAnalyzer.getStackTrace(),
//                                         status);
            completion(resultAnalyzer.isStatusOk())
        }
    }
    
    /// <summary>
    /// Calls the API with result.
    /// </summary>
    /// <param name="commandName">Name of the command.</param>
    /// <param name="commandOption">The command option.</param>
    /// <exception cref="System.ArgumentNullException">commandName is null!</exception>
    /// <exception cref="AceQLException">
    /// HTTP_FAILURE" + " " + httpStatusDescription - 0
    /// or
    /// or
    /// 0
    /// </exception>
    func callApiWithResultAsync(commandName: String, commandOption: String, completion: @escaping(String?, Bool) -> Void)
    {
        callWithGetAsync(action: commandName, actionParameter: commandOption) { result, status in
            let resultAnalyzer = ResultAnalyzer(jsonResult: result, httpStatusCode: status!)
//            if (!resultAnalyzer.isStatusOk()) {
    //            throw new AceQLException(resultAnalyzer.GetErrorMessage(),
    //                                     resultAnalyzer.GetErrorId(),
    //                                     resultAnalyzer.GetStackTrace(),
    //                                     httpStatusCode);
//            }
            
            completion(resultAnalyzer.GetResult(), resultAnalyzer.isStatusOk())
        }
    }
    
    
    /// <summary>
    /// Calls the with get.
    /// </summary>
    /// <param name="action">The action.</param>
    /// <param name="actionParameter">The action parameter.</param>
    /// <returns>String.</returns>
    func callWithGetAsync(action: String, actionParameter: String, completion: @escaping([String: Any]?, HTTPURLResponse?) -> Void)
    {
        var urlWithaction = self.url + action
        
        if (actionParameter.count != 0)
        {
            urlWithaction += "/" + actionParameter;
        }
        
        callWithGetAsync(url: urlWithaction) { result, status in
            completion(result, status)
        }
    
    }
    
    /// <summary>
    /// Calls the with get.
    /// </summary>
    /// <param name="url">The URL.</param>
    /// <returns>String.</returns>
    /// <exception cref="System.ArgumentNullException">url is null!</exception>
    func callWithGetAsync(url: String, completion: @escaping([String: Any]?, HTTPURLResponse?) -> Void)
    {
        callWithGetReturnStreamAsync(url: url) { result, status in
            AceQLHttpApi.traceAsync()
            AceQLHttpApi.traceAsync(contents: "----------------------------------------")
            AceQLHttpApi.traceAsync(contents: url)
            if (result != nil) {
                AceQLHttpApi.traceAsync(contents: result!.description)
            }
            AceQLHttpApi.traceAsync(contents: "----------------------------------------")
            
            completion(result, status)
            
        }
    }
    
    
    func executeQueryAsync(cmdText: String, isPreparedStatement: Bool, statementParameters: [String: String]?, completion: @escaping([String: Any]?, HTTPURLResponse?) -> Void)
    {
        let action = "execute_query";
    
        var parametersMap = ["sql": cmdText,
                             "prepared_statement": String(isPreparedStatement),
                             "column_types": "true",
                             "gzip_result": String(gzipResult),
                             "pretty_printing": String(prettyPrinting)]
    
        if (statementParameters != nil) {
            let keyList = statementParameters!.keys
            for key in keyList
            {
                parametersMap[key] = statementParameters?[key]
            }
        }
        
        
        callWithPostAsync(action: action, parameters: parametersMap) { result, status in
            completion(result, status)
        }
    }
    
    func executeUpdateAsync(sql: String, isPreparedStatement: Bool, statementParameters: [String: String]?, completion:@escaping (Int, Bool) -> Void)
    {
        let action = "execute_update";
        
        var parametersMap = ["sql": sql,
                             "prepared_statement": String(isPreparedStatement)]
        
        if (statementParameters != nil) {
            let keyList = statementParameters!.keys
            for key in keyList
            {
                parametersMap[key] = statementParameters![key]
            }
        }
        
        callWithPostAsync(action: action, parameters: parametersMap) {result, status in
            let resultAnalyzer = ResultAnalyzer(jsonResult: result, httpStatusCode: status)
//            if (!resultAnalyzer.isStatusOk()) {
//                throw new AceQLException(resultAnalyzer.GetErrorMessage(),
//                                         resultAnalyzer.GetErrorId(),
//                                         resultAnalyzer.GetStackTrace(),
//                                         httpStatusCode);
//            }
            
            let rowCount = resultAnalyzer.GetIntvalue(name: "row_count")
            completion(rowCount, resultAnalyzer.isStatusOk())
//            return rowCount
        }
    }
    
    
    /// <summary>
    /// Uploads a Blob/Clob on the server.
    /// </summary>
    /// <param name="blobId">the Blob/Clob Id</param>
    /// <param name="stream">the stream of the Blob/Clob</param>
    /// <param name="totalLength">the total length of all BLOBs to upload</param>
    /// <returns>The result as JSON format.</returns>
    /// <exception cref="System.ArgumentNullException">
    /// blobId is null!
    /// or
    /// file is null!
    /// </exception>
    /// <exception cref="System.IO.FileNotFoundException">file does not exist: " + file</exception>
    /// <exception cref="AceQLException">HTTP_FAILURE" + " " + httpStatusDescription - 0</exception>
    func blobUploadAsync(blobId: String? , stream: Data?, totalLength: Int64, completion: @escaping([String: Any]?) -> Void)
    {
        if (blobId == nil)
        {
//            throw new ArgumentNullException("blobId is null!");
            completion(nil)
            return;
        }

        if (stream == nil)
        {
//            throw new ArgumentNullException("stream is null!");
            completion(nil)
            return;
        }

        let theUrl = self.url + "blob_upload"
        
        let url = URL(string: theUrl)!
        let config = URLSessionConfiguration.default
        var request = URLRequest(url: url)

        let params = ["blob_id" : blobId!]
        let boundary = generateBoundaryString()
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = createBodyWithParameters(parameters: params, filePathKey: "file", data: stream!, boundary: boundary)
        
        let session = URLSession(configuration: config)
        if (self.proxyUri != nil) {
            var proxyConfiguration = [NSObject: AnyObject]()
            proxyConfiguration[kCFNetworkProxiesHTTPEnable] = true as AnyObject
            proxyConfiguration[kCFProxyUsernameKey] = self.userName! as AnyObject
            proxyConfiguration[kCFProxyPasswordKey] = self.password! as AnyObject
            proxyConfiguration[kCFNetworkProxiesHTTPProxy] = self.proxyUri! as AnyObject
            config.connectionProxyDictionary = proxyConfiguration
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                completion(nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                completion(nil)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            completion(json!)
            
        }
        task.resume()
    }
    
    var buffer:NSMutableData = NSMutableData()
    var expectedContentLength = 0
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        expectedContentLength = Int(response.expectedContentLength)
        print(expectedContentLength)
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        print("buffer length =  \(buffer.length)");
        print("progress =  \(buffer.length * 100 / expectedContentLength)");
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, data: Data!, boundary: String) -> Data {
        var body = Data();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(String(describing: parameters!["blob_id"]!))\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        
        body.append(data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
//    / <summary>
//    / Returns the server Blob/Clob length.
//    / </summary>
//    / <param name="blobId">the Blob/Clob Id.</param>
//    / <returns>the server Blob/Clob length.</returns>
    func getBlobLengthAsync(blobId: String, completion: @escaping(Int64, Bool) -> Void)
    {
        let action = "get_blob_length";

        let parametersMap = ["blob_id": blobId]
//        String result = null;

        callWithPostAsync(action: action, parameters: parametersMap) {result, status in
            
            let resultAnalyzer = ResultAnalyzer(jsonResult: result, httpStatusCode: status!)
            if (!resultAnalyzer.isStatusOk())
            {
//                throw new AceQLException(resultAnalyzer.GetErrorMessage(),
//                                         resultAnalyzer.GetErrorId(),
//                                         resultAnalyzer.GetStackTrace(),
//                                         httpStatusCode);
            }
            
            let lengthStr = resultAnalyzer.getValue(name: "length");
            let length = Int64(lengthStr!)
            completion(length!, resultAnalyzer.isStatusOk())
        }
    }
    
    
    /// <summary>
    /// Downloads a Blob/Clob from the server.
    /// </summary>
    /// <param name="blobId">the Blob/Clob Id</param>
    ///
    /// <returns>the Blob input stream</returns>
    func blobDownloadAsync(blobId: String, completion: @escaping(Data?) -> Void)
    {
        let theUrl = self.url + "/blob_download?blob_id=" + blobId;
        blobDownload(url: theUrl) { data, status in
            completion(data)
        }
    }
    
    /// <summary>
    /// Says if trace is on
    /// </summary>
    /// <returns>true if trace is on</returns>
    static func isTraceOn() -> Bool
    {
        return AceQLHttpApi.TRACE_ON;
    }
    
    /// <summary>
    /// Sets the trace on/off
    /// </summary>
    /// <param name="traceOn">if true, trace will be on; else race will be off</param>
    static func setTraceOn(traceOn: Bool)
    {
        AceQLHttpApi.TRACE_ON = traceOn;
    }
    
    /// <summary>
    /// To be call at end of each of each public aysnc(CancellationToken) calls to reset to false the usage of a CancellationToken with http calls
    /// and some reader calls.
    /// </summary>
    func resetCancellationToken()
    {
        self.useCancellationToken = false;
    }
    
    /// <summary>
    /// Sets the CancellationToken asked by user to pass for the current public xxxAsync() call api.
    /// </summary>
    /// <param name="cancellationToken">CancellationToken asked by user to pass for the current public xxxAsync() call api.</param>
    func setCancellationToken()
    {
        self.useCancellationToken = true;
    //    this.cancellationToken = cancellationToken;
    }
    
    /// <summary>
    /// Returns the progress indicator variable that will store Blob/Clob upload or download progress between 0 and 100.
    /// </summary>
    /// <returns>The progress indicator variable that will store Blob/Clob upload or download progress between 0 and 100.</returns>
    func getProgressIndicator() -> AceQLProgressIndicator
    {
        return progressIndicator
    }
    
    
    /// <summary>
    /// Sets the progress indicator variable that will store Blob/Clob upload or download progress between 0 and 100. Will be used by progress indicators to show the progress.
    /// </summary>
    /// <param name="progressIndicator">The progress variable.</param>
    func setProgressIndicator(progressIndicator: AceQLProgressIndicator)
    {
        self.progressIndicator = progressIndicator;
    }
    
    /// <summary>
    /// Returns the SDK current Version.
    /// </summary>
    /// <returns>the SDK current Version.</returns>
    func getVersion() -> String
    {
        return Version.GetVersion()
    }
    
    ///// <summary>
    ///// Creates a new object that is a copy of the current instance.
    ///// </summary>
    ///// <returns>A new object that is a copy of this instance.</returns>
    //internal object Clone()
    //{
    //    return new AceQLHttpApi();
    //}
    
    
    /// <summary>
    /// Closes the connection to the remote database and closes the http session.
    /// </summary>
    func closeAsync()
    {
        callApiNoResultAsync(commandName: "disconnect", commandOption: ""){status in}
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

extension Data {
    mutating func appendString(string: String) {
        append(string.data(using: .utf8)!)
    }
}
