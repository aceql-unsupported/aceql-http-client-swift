//
//  AceQLParameterCollection.swift
//  AceQL.Client
//
//  Created by KawanSoft / Bruno Paul on 11/12/17.
//  Copyright © 2017 KawanSoft. All rights reserved.
//

import Foundation

class AceQLParameterCollection {
    var DEBUG: Bool = false
    
    /// <summary>
    /// The AceQL Parameters
    /// </summary>
    var aceqlParameters = [AceQLParameter]()
    var cmdText: String
    
    /// <summary>
    /// Initializes a new instance of the <see cref="AceQLParameterCollection"/> class.
    /// </summary>
    /// <param name="cmdText">The SQL command text.</param>
    /// <exception cref="System.ArgumentNullException">If cmdText is null.</exception>
    init(cmdText: String)
    {
        self.cmdText = cmdText
    }
    
    /// <summary>
    /// Specifies the number of items in the collection.
    /// </summary>
    /// <value>The number of items in the collection.</value>
    func count() -> Int {
        return aceqlParameters.count
    }
    
    /// <summary>
    /// Specifies whether the collection is read-only.
    /// </summary>
    /// <value><c>true</c> if this instance is read only; otherwise, <c>false</c>.</value>
    func isReadOnly() -> Bool
    {
        return false
    }
    
    /// <summary>
    /// Returns parameter at specified index.
    /// </summary>
    /// <param name="index">The index.</param>
    /// <returns>the <see cref="AceQLParameter"/> at index.</returns>
    func getIndex(index: Int) -> AceQLParameter {
        return aceqlParameters[index]
    }
    
    /// <summary>
    /// Removes all <see cref="AceQLParameter"/> objects from the <see cref="AceQLParameterCollection"/>
    /// </summary>
    func clear() -> Void
    {
        aceqlParameters.removeAll()
    }
    
    /// <summary>
    /// Determines whether the specified parameter name is in this <see cref="AceQLParameterCollection"/>.
    /// </summary>
    /// <param name="value">The value.</param>
    /// <returns>true if the <see cref="AceQLParameterCollection"/> contains the value; otherwise false.</returns>
    func contains(value: String) -> Bool
    {
        for aceQLParameter in aceqlParameters
        {
            if (aceQLParameter.parameterName == value) {
                return true;
            }
        }
        return false;
    }
    
    /// <summary>
    /// Determines whether the specified System.Object is in this <see cref="AceQLParameterCollection"/>.
    /// </summary>
    /// <param name="value">The value.</param>
    /// <returns>true if the <see cref="AceQLParameterCollection"/> contains the value; otherwise false.</returns>
    func Contains(value: String) -> Bool
    {
        for aceQLParameter in aceqlParameters
        {
            if (aceQLParameter.value as! String == value)
            {
                return true;
            }
        }
        return false;
    }
    
    
    /// <summary>
    ///  Gets the location of the specified <see cref="AceQLParameter"/> with the specified name.
    /// </summary>
    /// <param name="parameterName">Name of the parameter.</param>
    /// <returns> The case-sensitive name of the <see cref="AceQLParameter"/> to find.</returns>
    /// <exception cref="System.ArgumentNullException">If parameterName is null.</exception>
    func indexOf(parameterName: String) -> Int
    {
        for i in 0...aceqlParameters.count - 1
        {
            let aceQLParameter = aceqlParameters[i]
            if (aceQLParameter.parameterName == parameterName)
            {
                return i;
            }
        }
        return -1;
    }
    
    /// <summary>
    ///  Adds a value to the end of the <see cref="AceQLParameterCollection"/>.
    /// </summary>
    /// <param name="parameterName">The name of the parameter.</param>
    /// <param name="value">The value to be added. Cannot ne bull.</param>
    /// <exception cref="System.ArgumentNullException">If parameterName or value is null.</exception>
    func addWithValue(parameterName: String, value: Any?)
    {
        let aceQLParameter = AceQLParameter(parameterName: parameterName,value: value)
        aceqlParameters.append(aceQLParameter)
    
    }
    
    /// <summary>
    /// Adds a value to the end of the <see cref="AceQLParameterCollection"/>.
    /// To be used for Blobs insert or update.
    /// </summary>
    /// <param name="parameterName">Name of the parameter.</param>
    /// <param name="stream">The Blob stream to read. Cannot be null.</param>
    /// <param name="length">The Blob stream length.</param>
    /// <exception cref="System.ArgumentNullException">If parameterName or stream is null.</exception>
    func addWithValue(parameterName: String, stream:[String: Any]?, length: Int64)
    {
        let aceQLParameter = AceQLParameter(parameterName: parameterName, value: stream, length: length);
        aceqlParameters.append(aceQLParameter);
        debug(log: parameterName + " SqlType: " + String(describing:aceQLParameter.sqlType));
    }
    
    /// <summary>
    /// Adds the specified <see cref="AceQLParameter"/>. object to the <see cref="AceQLParameterCollection"/>.
    /// </summary>
    /// <param name="value">The <see cref="AceQLParameter"/> to add to the collection.</param>
    /// <exception cref="System.ArgumentNullException">If value is null.</exception>
    func add(value: AceQLParameter)
    {
        aceqlParameters.append(value);
    }
    
    
    /// <summary>
    ///  Gets the location of the specified <see cref="Object"/> within the collection.
    /// </summary>
    /// <param name="value">The <see cref="Object"/> to find.</param>
    /// <returns> The zero-based location of the specified <see cref="Object"/> that is a <see cref="AceQLParameter"/> within the collection. Returns -1 when the object does not exist in the <see cref="AceQLParameterCollection"/>.</returns>
    /// <exception cref="System.ArgumentNullException">If parameterName is null.</exception>
    func indexOf(value: Any?) -> Int
    {
        //if (value == null)
        //{
        //    throw new ArgumentNullException("value is null!");
        //}
    
//        for (int i = 0; i < aceqlParameters.Count; i++)
//        {
//            AceQLParameter aceQLParameter = aceqlParameters[i];
//            if (aceQLParameter.Value.Equals(value))
//            {
//                return i;
//            }
//        }
        return -1;
    }
    
    /// <summary>
    /// Inserts an <see cref="Object"/>into the <see cref="AceQLParameterCollection"/> at the specified index.
    /// Not implemented.
    /// </summary>
    /// <param name="index">The zero-based index at which value should be inserted.</param>
    /// <param name="value">An <see cref="Object"/> to be inserted in the <see cref="AceQLParameterCollection"/>.</param>
    /// <exception cref="System.NotSupportedException"></exception>
    func insert(index: Int, value: Any?)
    {
//    throw new NotSupportedException();
    }
    
    /// <summary>
    /// Removes the specified <see cref="AceQLParameter"/> from the collection.
    /// </summary>
    /// <param name="value">The object to remove from the collection.</param>
    func remove(value: Any?)
    {
//        for i in 0...aceqlParameters.count
//        {
//        let aceQLParameter = aceqlParameters[i]
//            if (aceQLParameter.value == value)
//            {
//                aceqlParameters.remove(at: i)
//                return;
//            }
//        }
    }
    
    /// <summary>
    ///  Removes the <see cref="AceQLParameter"/> from the <see cref="AceQLParameterCollection"/>
    ///  at the specified parameter name.
    /// </summary>
    /// <param name="parameterName">The name of the <see cref="AceQLParameter"/> to remove.</param>
    func removeAt(parameterName: String)
    {
        for i in 0...aceqlParameters.count - 1
        {
            let aceQLParameter = aceqlParameters[i]
            if (aceQLParameter.parameterName == parameterName)
            {
                aceqlParameters.remove(at: i)
                return;
            }
        }
    }
    
    /// <summary>
    ///  Removes the <see cref="AceQLParameter"/> from the <see cref="AceQLParameterCollection"/>
    ///  at the specified index.
    /// </summary>
    /// <param name="index">The zero-based index of the <see cref="AceQLParameter"/> object to remove.</param>
    func removeAt(index: Int)
    {
        aceqlParameters.remove(at: index)
    }
    
    /// <summary>
    /// Gets the <see cref="AceQLParameter"/> for it's name.
    /// </summary>
    /// <param name="parameterName">Name of the <see cref="AceQLParameter"/>.</param>
    /// <returns>The <see cref="AceQLParameter"/> for the parameter name.</returns>
    func getAceQLParameter(parameterName: String) -> AceQLParameter?
    {
        for i in 0...aceqlParameters.count - 1
        {
            let aceQLParameter = aceqlParameters[i]
            if (aceQLParameter.parameterName == parameterName)
            {
                return aceQLParameter
            }
        }
    
        return nil
    }
    
    /// <summary>
    /// Gets the <see cref="AceQLParameter"/> at the index.
    /// </summary>
    /// <param name="index">The index of <see cref="AceQLParameter"/>.</param>
    /// <returns>The <see cref="AceQLParameter"/> at index position.</returns>
    func getParameter(index: Int) -> AceQLParameter
    {
        return aceqlParameters[index]
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
