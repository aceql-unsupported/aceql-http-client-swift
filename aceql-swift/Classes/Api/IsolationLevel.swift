//
//  IsolationLevel.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation


public enum IsolationLevel : Int
{
    /// <summary>
    /// A different isolation level than the one specified is being used, but the level cannot be determined.
    /// </summary>
    case Unspecified = -1
    
    /// <summary>
    /// A dirty read is possible, meaning that no shared locks are issued and no exclusive locks are honored.
    /// </summary>
    case ReadUncommitted = 256
    
    /// <summary>
    /// Shared locks are held while the data is being read to avoid dirty reads, but the data can be changed before the end of the transaction, resulting in non-repeatable reads or phantom data.
    /// </summary>
    case ReadCommitted = 4096
    
    /// <summary>
    /// Locks are placed on all data that is used in a query, preventing other users from updating the data. Prevents non-repeatable reads but phantom rows are still possible.
    /// </summary>
    case RepeatableRead = 65536
    
    /// <summary>
    ///A range lock is placed, preventing other users from updating or inserting rows into the dataset until the transaction is complete.
    /// </summary>
    case Serializable = 1048576
}

