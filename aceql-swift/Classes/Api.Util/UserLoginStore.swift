//
//  UserLoginStore.swift
//  AceQL.Sample
//
//  Created by Tiger on 05.02.18.
//  Copyright © 2018 X. All rights reserved.
//

import Foundation

class UserLoginStore {
    static var loggedUsers = Dictionary<String, String>()
    var serverUrl: String = ""
    var username: String = ""
    var database: String = ""
    
    /// <summary>
    /// Initializes a new instance of the <see cref="UserLoginStore"/> class.
    /// </summary>
    /// <param name="serverUrl">The AceQL server URL.</param>
    /// <param name="username">the client username.</param>
    /// <param name="database">The database to which users wants to connect</param>
    /// <exception cref="ArgumentNullException">
    /// serverUrl is null!
    /// or
    /// username is null!
    /// or
    /// database is null!
    /// </exception>
    init (serverUrl: String?, username: String?, database: String?)
    {
        if (serverUrl == nil)
        {
            AceQLException.ThrowException(type: 0, httpCode: 0, httpStatus: "", description: "serverUrl is null")
            return
        }
        
        self.serverUrl = serverUrl!
        
        if (username == nil)
        {
            AceQLException.ThrowException(type: 0, httpCode: 0, httpStatus: "", description: "username is null")
            return
        }
        
        self.username = username!

        if (database == nil)
        {
            AceQLException.ThrowException(type: 0, httpCode: 0, httpStatus: "", description: "database is null")
            return
        }
        
        self.database = database!
    }
    
    
    /// <summary>
    /// Says if user is already logged (ie. it exist a session_if for (serverUrl, username, database) triplet.
    /// </summary>
    /// <returns>
    ///   <c>true</c> if [is already logged]; otherwise, <c>false</c>.
    /// </returns>
    func IsAlreadyLogged() -> Bool
    {
        let key = BuildKey()
        return UserLoginStore.loggedUsers[key] != nil
    }
    
    /// <summary>
    /// Returns the session If of logged user with (serverUrl, username, database) triplet.
    /// </summary>
    /// <returns>the stored session Id for the (serverUrl, username, database) triplet.</returns>
    func GetSessionId() -> String?
    {
        let key = BuildKey()
        let sessionId = UserLoginStore.loggedUsers[key]
        return sessionId
    }
    
    /// <summary>
    /// Stores the session Id of a logged user with (serverUrl, username, database) triplet.
    /// </summary>
    /// <param name="sessionId">The session Id of a logged user.</param>
    func SetSessionId(sessionId: String)
    {
        let key = BuildKey()
        UserLoginStore.loggedUsers[key] = sessionId
    }
    
    /// <summary>
    /// Removes (serverUrl, username, database) triplet. This is to be called at /logout API.
    /// </summary>
    func Remove()
    {
        let key = BuildKey()
        UserLoginStore.loggedUsers.removeValue(forKey: key)
    }
    
    /// <summary>
    /// Builds the key.
    /// </summary>
    /// <returns>The built key</returns>
    func BuildKey() -> String
    {
        return serverUrl + "/" + username + "/" + database
    }
}
