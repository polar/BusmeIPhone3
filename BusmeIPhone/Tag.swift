//
//  Tag.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/30/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation

class Tag {
    var name: String = "";
    var attributes: Dictionary<String,String> = Dictionary<String,String>();
    var childNodes: [Tag] = Array<Tag>();
    var text: String? = "";
    
    init(tag: RXMLElement) {
        self.name = tag.tag;
        for name in tag.attributeNames() {
            let x = tag.attribute(name as String);
            self.attributes.updateValue(x as String, forKey: name as String);
        }
        // Doesn't work. You need to match the name of the children exactly.
        //let kids = tag.children("") as [RXMLElement];
        var kids = Array<RXMLElement>();
        tag.iterate("*", usingBlock: {
            (RXMLElement x) -> Void in
            kids.append(x)
        });
        for t in kids {
            let x = Tag(tag: t);
            self.childNodes.append(x);
        }
        //let children = tag.children("*");
        //self.childNodes = children.map({(RXMLElement elem) in Tag(tag: elem as RXMLElement)});
        self.text = tag.text;
    }
}