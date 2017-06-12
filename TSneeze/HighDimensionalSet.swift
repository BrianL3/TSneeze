//
//  HighDimensionalSet.swift
//  TSneeze
//
//  Created by Brian Ledbetter on 6/23/16.
//  Copyright © 2016 Brian Ledbetter. All rights reserved.
//

import Foundation

struct HighDimensionalSet {
    var comparables : [SimilarityComparable]
    var classifications : [String]?
    var sigmas : [Double]?
    
    init(dataSet : [SimilarityComparable]) {
        self.comparables = dataSet
        
    }

    init(dataSet : [SimilarityComparable], sigmas : [Double]?, classifications : [String]?) {
        self.comparables = dataSet
        self.sigmas = sigmas
        self.classifications = classifications
    }
    
    // compute pairwise comparison in all vectors in the high dimensional data set (aka convert X to D)
    // this is sometimes called a similarity matrix (but we have the matrix in vector form)
    static func convertToDistancesVectors(_ X : [SimilarityComparable]) -> ([Double], [Double]?) {
        print("Started HighDimensionalSet class function for X size of \(X.count)")
        var distanceVector = [Double](repeating: 0.0, count: X.count * X.count)
        var sigmas : [Double]?
        for i in 0 ..< X.count {
            for j in i+1 ..< X.count {
                if let distanceAndSigma = ImageDataPoint.compare(X[i], second : X[j]) {
                    distanceVector[(i*X.count+j)] = distanceAndSigma.0
                    distanceVector[(j*X.count+i)] = distanceAndSigma.0
                    if let validSigma = distanceAndSigma.1 {
                        if (i == 0) { print("Returned point comparison had a sigma value") }
                        if sigmas != nil {
                            sigmas!.append(validSigma)
                        } else {
                            sigmas = [Double]()
                            sigmas!.append(validSigma)
                        }
                    }
                } else {
                    print("Failed to receive a non-nil response from high-D point comparison.")
                }
            }
        }
        return (distanceVector, sigmas)
    }
}
