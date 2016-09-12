//
//  DataDigester.swift
//  TSneeze
//
//  Created by Brian Ledbetter on 6/15/16.
//  Copyright © 2016 Brian Ledbetter. All rights reserved.
//
import Foundation
import CoreGraphics
//def _joint_probabilities_constant_sigma(D, sigma):
//P = np.exp(-D**2/2 * sigma**2)
//P /= np.sum(P, axis=1)
//return P
class DataDigester {

    /*
     The pendigits base data is in a CSV File: A raw data point is an array of 8 (X,Y) pairings, each representing a point of contact while handwriting a digit.  The final value in the array is the classication of the digit being written, e.g. "1".  The data points are normalized for timing. There are almost 7500 points.
    */
    
    /*
     This will fill digitData an array of DataPoint objects, each representing a row from the CSV.
     */
    func formatPendigitsData(pendigitsData: ([DataPoint]) ->()) {
        CSVScanner.decodeDataPointsFromFile(fileName: "pendigits") { (validDataPoints) in
            pendigitsData(validDataPoints)
        }
    }
    
    
//    func createSimilarityMatrix(dataPoints : [DataPoint], completedMatrix:([[Double]])->()) {
//        print("==== Creating Similarity Matrix ====")
//        print("for data set of size \(dataPoints.count)")
//        var similarityMatrix = [[Double]]()
//        var distanceVector = [Double](count: dataPoints.count * dataPoints.count, repeatedValue : 0.0)
//        for r in 0 ..< dataPoints.count {
//            
//            var rowMatrix = [Double]()
//            for c in 0 ..< dataPoints.count {
//                if (r == c) {
//                    rowMatrix.append(1.0)
//                }
//                if (c < r) {
//                    // the similarity matrix is symetric, so if the column is less than the row
//                    // the similarity result will be the same as rows[c]
//                    rowMatrix.append(similarityMatrix[c][r])
//                }
//                if (c > r) {
//                    print("Comparing points at \(r) and \(c): \(dataPoints[r].points) vs \(dataPoints[c].points)")
//                    rowMatrix.append(dataPoints[r].compare(dataPoints[c]))
//                }
//            }
//            similarityMatrix.append(rowMatrix)
//            
//        }
//        completedMatrix(similarityMatrix)
//    }
    
    
    
}