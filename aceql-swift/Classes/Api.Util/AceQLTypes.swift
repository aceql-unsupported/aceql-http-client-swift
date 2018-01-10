//
//  AceQLTypes.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

class AceQLTypes {
    static let BINARY: String = "BINARY"
    static let BIT: String = "BIT"
    static let BLOB: String = "BLOB"
    static let CHAR: String = "CHAR"
    static let CHARACTER: String = "CHARACTER"
    static let CLOB: String = "CLOB"
    static let DATE: String = "DATE"
    static let DECIMAL: String = "DECIMAL"
    static let DOUBLE_PRECISION: String = "DOUBLE PRECISION"
    static let FLOAT: String = "FLOAT"
    static let INTEGER: String = "INTEGER"
    static let LONGVARBINARY: String = "LONGVARBINARY"
    static let LONGVARCHAR: String = "LONGVARCHAR"
    static let NUMERIC: String = "NUMERIC"
    static let REAL: String = "REAL"
    static let SMALLINT: String = "SMALLINT"
    static let TIME: String = "TIME"
    static let TIMESTAMP: String = "TIMESTAMP"
    static let TINYINT: String = "TINYINT"
    static let URL: String = "URL"
    static let VARBINARY: String = "VARBINARY"
    static let VARCHAR: String = "VARCHAR"
    
    static func isDateTimeType(colType: String) -> Bool
    {
        if (colType == AceQLTypes.DATE || colType == AceQLTypes.TIME || colType == AceQLTypes.TIMESTAMP)  {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    static func isStringType(colType: String) -> Bool
    {
        if (colType == AceQLTypes.CHAR || colType == AceQLTypes.CHARACTER || colType == AceQLTypes.VARCHAR)  {
            return true;
        }
        else
        {
            return false;
        }
    }
}
