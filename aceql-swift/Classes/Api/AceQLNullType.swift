//
//  AceQLNullType.swift
//  AceQL.Client
//
//  Created by Xander Addison on 11/12/17.
//  Copyright © 2017 X. All rights reserved.
//

import Foundation

public enum AceQLNullType: Int {
    /// <summary>
    /// SQL type BIT.
    /// </summary>
    case BIT = -7
    
    /// <summary>
    /// SQL type TINYINT.
    /// </summary>
    case TINYINT = -6
    
    /// <summary>
    /// SQL type SMALLINT.
    /// </summary>
    case SMALLINT = 5
    
    /// <summary>
    /// SQL type INTEGER.
    /// </summary>
    case INTEGER = 4
    
    /// <summary>
    /// SQL type BIGINT.
    /// </summary>
    case BIGINT = -5
    
    /// <summary>
    /// SQL type FLOAT.
    /// </summary>
    case FLOAT = 6
    
    /// <summary>
    /// SQL type REAL.
    /// </summary>
    case REAL = 7
    
    /// <summary>
    /// SQL type DOUBLE.
    /// </summary>
    case DOUBLE = 8
    
    /// <summary>
    /// SQL type NUMERIC.
    /// </summary>
    case NUMERIC = 2
    
    /// <summary>
    /// SQL type DECIMAL.
    /// </summary>
    case DECIMAL = 3
    
    /// <summary>
    /// SQL type CHAR.
    /// </summary>
    case CHAR = 1
    
    /// <summary>
    /// SQL type VARCHAR.
    /// </summary>
    case VARCHAR = 12
    
    ///// <summary>
    ///// SQL type LONGVARCHAR.
    ///// </summary>
    //LONGVARCHAR = -1,
    
    /// <summary>
    /// SQL type DATE.
    /// </summary>
    case DATE = 91
    
    /// <summary>
    /// SQL type TIME.
    /// </summary>
    case TIME = 92
    
    /// <summary>
    /// SQL type TIMESTAMP.
    /// </summary>
    case TIMESTAMP = 93
    
    ///// <summary>
    ///// SQL type BINARY.
    ///// </summary>
    //BINARY = -2,
    
    ///// <summary>
    ///// SQL type VARBINARY.
    ///// </summary>
    //VARBINARY = -3,
    
    ///// <summary>
    ///// SQL type LONGVARBINARY.
    ///// </summary>
    //LONGVARBINARY = -4,
    
    ///// <summary>
    ///// The null
    ///// </summary>
    //NULL = 0,
    
    ///// <summary>
    ///// The other
    ///// </summary>
    //OTHER = 1111,
    
    ///// <summary>
    ///// The java object
    ///// </summary>
    //JAVA_OBJECT = 2000,
    
    ///// <summary>
    ///// The distinct
    ///// </summary>
    //DISTINCT = 2001,
    
    ///// <summary>
    ///// The structure
    ///// </summary>
    //STRUCT = 2002,
    
    ///// <summary>
    ///// The array
    ///// </summary>
    //ARRAY = 2003,
    
    /// <summary>
    /// SQL type BLOB.
    /// </summary>
    case BLOB = 2004
    
    /// <summary>
    /// SQL type CLOB.
    /// </summary>
    case CLOB = 2005
    
    ///// <summary>
    ///// The reference
    ///// </summary>
    //REF = 2006,
    
    ///// <summary>
    ///// The datalink
    ///// </summary>
    //DATALINK = 70,
    
    /// <summary>
    /// SQL type BOOLEAN.
    /// </summary>
    case BOOLEAN = 16
    
    //------------------------- JDBC 4.0 -----------------------------------
    
    ///// <summary>
    ///// The rowid
    ///// </summary>
    //ROWID = -8,
    
    ///// <summary>
    ///// The nchar
    ///// </summary>
    //NCHAR = -15,
    
    ///// <summary>
    ///// The nvarchar
    ///// </summary>
    //NVARCHAR = -9,
    
    ///// <summary>
    ///// SQL type LONGNVARCHAR
    ///// </summary>
    //LONGNVARCHAR = -16,
    
    ///// <summary>
    ///// The nclob
    ///// </summary>
    //NCLOB = 2011,
    
    
    ///// <summary>
    ///// The SQLXML
    ///// </summary>
    //SQLXML = 2009
}
