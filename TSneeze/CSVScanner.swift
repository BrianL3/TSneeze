//
//  CSVScanner.swift
//  TSneeze
//
//  Created by Brian Ledbetter on 6/15/16.
//  Copyright © 2016 Brian Ledbetter. All rights reserved.
//

import Foundation
import CoreGraphics

class CSVScanner {
    
    class func debug(string:String){
        
        print("CSVScanner: \(string)")
    }
    
    class func decodeFromFile(file : String, returnedDataSet : ([SimilarityComparable], [Double]?) -> ()) {
        
    }
    
    class func decodeImageMatricesFromFile(fileName: String, returnedSet : HighDimensionalSet -> ()) {
        if let strBundle = NSBundle.mainBundle().pathForResource(fileName, ofType: "csv") {
            do {
                let fileObject = try String(contentsOfFile: strBundle, encoding: NSUTF8StringEncoding)
                var fileObjectCleaned = fileObject.stringByReplacingOccurrencesOfString("\r", withString: "\n")
                
                fileObjectCleaned = fileObjectCleaned.stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
                let objectArray = fileObjectCleaned.componentsSeparatedByString("\n")
                
                var finishedImageDataPoints = [ImageDataPoint]()
                var classifications : [String]?
                
                for row in objectArray {
                    let objectColumns = row.componentsSeparatedByString(",")
                    
                    var pointsArray = [Double]()
                    var classification = 0
                    
                    for c in 0 ..< objectColumns.count {
                        
                        if (c == objectColumns.count - 1) {
                            if (classifications == nil) {
                                classifications = [String]()
                            }
                            classifications!.append(objectColumns[c].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                            guard let classificationNumber = Int(objectColumns[c].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) else { debug ("52"); continue }
                            classification = classificationNumber
                        } else {
                            guard let number = Double(objectColumns[c]) else { debug("failed to create number"); continue }
                            pointsArray.append(number)
                        }
                    }
                    if (pointsArray.count > 0) {
                        finishedImageDataPoints.append(ImageDataPoint(withPoints: pointsArray, withClassification: classification))
                    } else {
                        debug("Came across a line with CSVScanner which did not produce a data point with a point array.")
                    }
                }
                
                // coercion from [ImageDataPoint] to [SimilarityComparable] is not working?
                var sims = [SimilarityComparable]()
                for point in finishedImageDataPoints {
                    sims.append(point as SimilarityComparable)
                }
                // image data points finished
                returnedSet(HighDimensionalSet(dataSet: sims, sigmas: nil, classifications: classifications))
                
            } catch {
                debug("Unable to load csv file from path: \(strBundle)")
            }
        } else {
            debug("Unable to get string from bundle")
        }
    }
    
    class func decodeDataPointsFromFile(fileName theFileName:String, returnedPoints:([DataPoint])->()) {
        
        if let strBundle = NSBundle.mainBundle().pathForResource(theFileName, ofType: "csv") {
            //reading
            do {
                let fileObject = try String(contentsOfFile: strBundle, encoding: NSUTF8StringEncoding)
                var fileObjectCleaned = fileObject.stringByReplacingOccurrencesOfString("\r", withString: "\n")
                
                fileObjectCleaned = fileObjectCleaned.stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
                
                let objectArray = fileObjectCleaned.componentsSeparatedByString("\n")
                var finishedDataPoints = [DataPoint]()
                for row in objectArray {
                    let objectColumns = row.componentsSeparatedByString(",")
                    
                    var columnIndex = 0
                    var tempX = 0
                    var tempY = 0
                    
                    var pointsArray = [CGPoint]()
                    var classification = 0
                    for column in objectColumns {
                        if (columnIndex == 16) {
                            guard let classificationNumber = Int(column.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) else { continue }
                            classification = classificationNumber
                            continue
                        }
                        if (columnIndex % 2 == 0) {
                            guard let x = Int(column.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) else { continue }
                            tempX = x
                        } else {
                            guard let y = Int(column.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) else { continue }
                            tempY = y
                            pointsArray.append(CGPoint(x: tempX, y: tempY))
                        }
                        columnIndex = columnIndex + 1
                    }
                    
                    finishedDataPoints.append(DataPoint(withPoints: pointsArray, withClassification: classification))
                }
                returnedPoints(finishedDataPoints)
            }
            catch {
                CSVScanner.debug("Unable to load csv file from path: \(strBundle)")
            }        }else{
            CSVScanner.debug("Unable to get path to csv file: \(theFileName).csv")
        }
    }
}
