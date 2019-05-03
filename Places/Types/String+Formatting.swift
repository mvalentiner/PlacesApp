//
//  String+Formatting.swift
//  Photos Here
//
//  Created by Michael on 3/3/15.
//  Copyright (c) 2015 Heliotropix. All rights reserved.
//

// From https://ericasadun.com/index.php?s=string+format

import Foundation

func stringWithFormat(_ format: String, args: CVarArg...) -> String {
    return NSString(format: format, arguments: getVaList(args)) as String
}

extension String {
    func format(_ args: CVarArg...) -> String {
        return NSString(format: self, arguments: getVaList(args)) as String
    }
}
