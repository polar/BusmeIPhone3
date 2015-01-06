//
//  Tag.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/30/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation

public class Tag {
    public var name: String = "";
    public var attributes: Dictionary<String,String> = Dictionary<String,String>();
    public var childNodes: [Tag] = Array<Tag>();
    public var text: String? = "";
    
    public init(tag: RXMLElement) {
        self.name = tag.tag;
        for name in tag.attributeNames() {
            let x = tag.attribute(name as String);
            self.attributes.updateValue(x as String, forKey: name as String);
        }
        // Stupid Fuck, this doesn't work you need to match the name of the children exactly.
        //let kids = tag.children("") as [RXMLElement];
        var kids = Array<RXMLElement>();
        tag.iterate("*", usingBlock: {
            (RXMLElement x) -> Void in
            kids.append(x)
        });
        NSLog("Kids %@", kids);
        NSLog("Kids %d", kids.count);
        for t in kids {
            let x = Tag(tag: t);
            NSLog("We got Child Tag %@", x.name);
            self.childNodes.append(x);
        }
        NSLog("Child nodes %d", self.childNodes.count);
        //let children = tag.children("*");
        //self.childNodes = children.map({(RXMLElement elem) in Tag(tag: elem as RXMLElement)});
        self.text = tag.text;
    }
}