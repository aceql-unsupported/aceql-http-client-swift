//
//  ConsoleEmul.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

class ConsoleEmul {
    static let CONSOLE_EMUL: String = "CONSOLE_EMUL";
    
    static func WriteLine()
    {
        print(ConsoleEmul.CONSOLE_EMUL)
    }
    
    static func WriteLine(log: String)
    {
        print("CONSOLE_EMUL" + " " + log);
    }
}
