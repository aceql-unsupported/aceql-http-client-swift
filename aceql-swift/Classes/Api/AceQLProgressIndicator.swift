//
//  AceQLProgressIndicator.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

open class AceQLProgressIndicator {
    /// <summary>   The perccent progress value set by upload thread.</summary>
    var percent: Int = 0
    
    /// <summary>
    /// Sets the value.
    /// </summary>
    /// <param name="value">The value.</param>
    func setValue(value: Int)
    {
        percent = value;
    }
}
