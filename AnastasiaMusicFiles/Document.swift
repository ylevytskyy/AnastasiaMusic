//
//  Document.swift
//  AnastasiaMusicFiles
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit

class Document: UIDocument {
    var contents: Data?
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let typeName = typeName, typeName == "public.audio" else { return }
        self.contents = contents as? Data
    }
}

