//
//  AceQLParameter.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

class AceQLParameter {
    /// <summary>
    /// The parameter name
    /// </summary>
    var parameterName: String
    /// <summary>
    /// The value
    /// </summary>
    var value: (Any)? = nil
    
    /// <summary>
    /// The database type
    /// </summary>
    var sqlType: AceQLNullType?
    
    var isNullValue: Bool = false;
    
    /// <summary>
    /// The length of the BLOB to upload
    /// </summary>
    var blobLength: Int64 = 0;
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLParameter"/> class to pass a NULL value to the remote
    /// database.
    /// </summary>
    /// <param name="parameterName">Name of the parameter to set with a NULL value.</param>
    /// <param name="value">The <see cref="AceQLNullType"/> value.</param>
    /// <exception cref="System.ArgumentNullException">If parameterName is null.</exception>
    init(parameterName: String, value: AceQLNullType)
    {
        var param = parameterName
        if (parameterName.prefix(1) != "@")
        {
            param = "@" + parameterName
        }
    
        self.parameterName = param
    
        isNullValue = true
        sqlType = value
    }
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLParameter"/> class.
    /// </summary>
    /// <param name="parameterName">Name of the parameter.</param>
    /// <param name="value">The value. Cannot be null.</param>
    /// <exception cref="System.ArgumentNullException">If parameterName or value is null.</exception>
    init(parameterName: String, value: (Any)?)
    {
        var param = parameterName
        if (parameterName.prefix(1) != "@")
        {
            param = "@" + parameterName
        }
        
        self.parameterName = param
        self.value = value
    }
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLParameter"/> class.
    /// To be used for Blobs.
    /// </summary>
    /// <param name="parameterName">Name of the parameter.</param>
    /// <param name="value">The Blob stream. Cannot be null.</param>
    /// <param name="length">The Blob stream length.</param>
    /// <exception cref="System.ArgumentNullException">If parameterName or value is null.</exception>
    convenience init (parameterName: String, value: [String: Any]?, length: Int64)
    {
        self.init(parameterName: parameterName, value: value)
        self.blobLength = length;
    }
}
