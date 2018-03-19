//
//  AceQLStatement.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

public class AceQLStatement {
    var aceQLConnection: AceQLConnection
    var aceQLHttpApi: AceQLHttpApi
    
    var sqlExecute: String
    
    public init()
    {
        aceQLConnection = AceQLConnection()
        aceQLHttpApi = AceQLHttpApi()
        sqlExecute = ""
    }
    
    public init (connection: AceQLConnection, sql: String)
    {
        aceQLConnection = connection
        aceQLHttpApi = aceQLConnection.aceQLHttpApi
        sqlExecute = sql
    }
    
    public func run(args: Any?..., completion: @escaping(String?, Bool) -> Void)
    {
        var command: AceQLCommand? = nil

        command = AceQLCommand(cmdText: self.sqlExecute, connection: self.aceQLConnection)
        
        command?.setPrepare()
        
        for index in 1...args.count{
            if (args[index - 1] is AceQLNullType)
            {
                command?.parameters.add(value: AceQLParameter(parameterName: "@param" + String(index), value: args[index - 1] as! AceQLNullType))
            }
            else
            {
                command?.parameters.addWithValue(parameterName: "@param" + String(index), value: args[index - 1])
            }
        }
        
        command?.executeNonQueryAsync() { result, status in
            print(result.description)
            if (!status)
            {
                self.rollbackAsync()
            }
            
            self.aceQLConnection.setRowsChanged(result: result.description)
            completion(result.description, status)
        }
    }
    
    public func rollbackAsync()
    {
        aceQLConnection.rollbackAsync() { success in }
    }
}
