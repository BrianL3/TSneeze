//
//  ImageDataPoint.swift
//  TSneeze
//
//  Created by Brian Ledbetter on 6/23/16.
//  Copyright © 2016 Brian Ledbetter. All rights reserved.
//

import Foundation
import CoreGraphics

struct ImageDataPoint : SimilarityComparable {
    var sigmas : [Double]?
    var points : [Double]?
    var predefinedClassification : Int?
    
    
    init(withPoints: [Double], withClassification: Int?) {
        self.points = withPoints
        self.predefinedClassification = withClassification
    }

    
    static func compare(first : SimilarityComparable, second: SimilarityComparable) -> (Double, Double?)? {
        if (first is ImageDataPoint && second is ImageDataPoint) {
            return ImageDataPoint.compareLinearDistance(first as! ImageDataPoint, second: second as! ImageDataPoint)
        } else {
            return nil
        }
    }
    
    // returns L2 distance between the two high dimensional points, and an optional sigma value (not in yet)
    static func compareLinearDistance(first : ImageDataPoint, second : ImageDataPoint) -> (Double, Double?)? {
        return (linearDistance(first.points!, vector2: second.points!), nil)
    }
    
    // compute L2 / euclidean linear distance between two vectors
    static func linearDistance(vector1 : [Double], vector2 : [Double]) -> Double {
//        var distance = 0.0
//        for i in 0..<vector1.count {
//            distance += (vector1[i] - vector2[i]) * (vector1[i] - vector2[i])
//        }
        
        var sum = 0.0
        for i in 0 ..< vector1.count {
            sum += abs(vector1[i] - vector2[i])
        }
        print(sum)
        return sum
        
//        var distanceArray = [Double]()
//        for i in 0 ..< vector1.count {
//            distanceArray.append(vector1[i] - vector2[i])
//        }
//        return distanceArray.reduce(0, combine: +)
//        var probabilities = [Double]()
//        
//        let sigma = 0.5
//        let e = M_E
//        
//        for distance in distanceArray {
//            probabilities.append(pow(distance, 2) / pow(e, (2 * pow(sigma, 2))))
//        }
//        
//        let logSum = probabilities.reduce(0,combine: +)
//        
//        return logSum

//        return distance
    }

    
    static func cartesianDistance(pointA : Double, pointB : Double, sigmaA: Double?, sigmaB : Double?) -> Double {
        if sigmaA == nil {
            return hypot(Double(pointA - pointB), Double(pointA - pointB))
        }
        return 1.0
        // question for Kyle: how do you deal with 2 points, each with their own independent sigma?  Average the sigmas?
//        var probabilities = [Double]()
//        
//        let sigma = 4.0
//        let e = M_E
//        
//        for distance in distanceArray {
//            probabilities.append(pow(distance, 2) / pow(e, (2 * pow(sigma, 2))))
//        }
//        
//        let logSum = probabilities.reduce(0,combine: +)
//        
//        return logSum

    }
    
    
    
    
}

extension SimilarityComparable {
    
    /*
     Similarity Comparables need some helper functions
    */
    
    // utility that creates contiguous vector of numbers(the fill value) of size n
    func vectorArray(size : Int, fill: Double) -> [Double] {
        return [Double](count: size, repeatedValue : fill)
    }
    
    // utility that creates 2D array numbers(the fill value) of size n
    func multiDVectorArray(size : Int, fill: Double, dimensions: Int) -> [[Double]] {
        var arrayToReturn = [[Double]]()
        for _ in 0 ..< size {
            for _ in 0 ..< dimensions {
                arrayToReturn.append([Double](count: size, repeatedValue : fill))
            }
        }
        return arrayToReturn
    }

}
