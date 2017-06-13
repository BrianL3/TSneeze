//
//  SimilarityComparable.swift
//  TSneeze
//
//  Created by Brian Ledbetter on 6/17/16.
//  Copyright © 2016 Brian Ledbetter. All rights reserved.
//

import Foundation

protocol SimilarityComparable {
    // Compare the similarity of two high-D data items.  Different High-D Items will have different 
    // methods of comparison.  Returns the similarity and the sigma value (how sure we are of the similarity)
    static func compare(_ first: SimilarityComparable, second : SimilarityComparable) -> (Double, Double?)?
}
