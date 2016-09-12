//
//  DataPoint.swift
//  TSneeze
//
//  Created by Brian Ledbetter on 6/17/16.
//  Copyright © 2016 Brian Ledbetter. All rights reserved.
//

import CoreGraphics
extension Float {
    func toDouble() -> Double? {
        if self > Float(Int.min) && self < Float(Int.max) {
            return Double(self)
        } else {
            return nil
        }
    }
}

struct DataPoint {
    var points = [CGPoint]()
    var classification : Int
    init(withPoints: [CGPoint], withClassification: Int) {
        self.points = withPoints
        self.classification = withClassification
    }
    
    func compare(withOtherComparator: SimilarityComparable) -> Double {
        guard let pointB = withOtherComparator as? DataPoint else { print("Error: failed to compare two points"); return 0.0 }
        if(pointB.points.count == 0) { print("The compared point has 0 points."); return 0.0 }
        var pointComparisonIndex = 0
        var distanceArray = [Double]()
        for point in points {
            let otherPoint = pointB.points[pointComparisonIndex]
            distanceArray.append(hypot(Double(point.x - otherPoint.x), Double(point.y - otherPoint.y)))
            
            pointComparisonIndex += 1
        }
        var probabilities = [Double]()
        
        let sigma = 4.0
        let e = M_E
        
        for distance in distanceArray {
            probabilities.append(pow(distance, 2) / pow(e, (2 * pow(sigma, 2))))
        }
        
        let logSum = probabilities.reduce(0,combine: +)
        
        return logSum
    }
    
    // compute L2 / euclidean linear distance between two vectors
    func linearDistance(vector1 : [Double], vector2 : [Double]) -> Double {
        var distance = 0.0
        for i in 0..<vector1.count {
            distance += (vector1[i] - vector2[i]) * (vector1[i] - vector2[i])
        }
        return distance
    }

    
}