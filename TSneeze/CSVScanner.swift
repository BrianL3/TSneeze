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
    
    class func debug(_ string:String){
        
        print("CSVScanner: \(string)")
    }
    
    class func decodeFromFile(_ file : String, returnedDataSet : ([SimilarityComparable], [Double]?) -> ()) {
        
    }
    
    class func decodeImageMatricesFromFile(_ fileName: String, returnedSet : (HighDimensionalSet) -> ()) {
        if let strBundle = Bundle.main.path(forResource: fileName, ofType: "csv") {
            do {
                let fileObject = try String(contentsOfFile: strBundle, encoding: String.Encoding.utf8)
                var fileObjectCleaned = fileObject.replacingOccurrences(of: "\r", with: "\n")
                
                fileObjectCleaned = fileObjectCleaned.replacingOccurrences(of: "\n\n", with: "\n")
                let objectArray = fileObjectCleaned.components(separatedBy: "\n")
                
                var finishedImageDataPoints = [ImageDataPoint]()
                var classifications : [String]?
                
                for row in objectArray {
                    let objectColumns = row.components(separatedBy: ",")
                    
                    var pointsArray = [Double]()
                    var classification = 0
                    
                    for c in 0 ..< objectColumns.count {
                        
                        if (c == objectColumns.count - 1) {
                            if (classifications == nil) {
                                classifications = [String]()
                            }
                            classifications!.append(objectColumns[c].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                            guard let classificationNumber = Int(objectColumns[c].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) else { debug ("52"); continue }
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
        
        if let strBundle = Bundle.main.path(forResource: theFileName, ofType: "csv") {
            //reading
            do {
                let fileObject = try String(contentsOfFile: strBundle, encoding: String.Encoding.utf8)
                var fileObjectCleaned = fileObject.replacingOccurrences(of: "\r", with: "\n")
                
                fileObjectCleaned = fileObjectCleaned.replacingOccurrences(of: "\n\n", with: "\n")
                
                let objectArray = fileObjectCleaned.components(separatedBy: "\n")
                var finishedDataPoints = [DataPoint]()
                for row in objectArray {
                    let objectColumns = row.components(separatedBy: ",")
                    
                    var columnIndex = 0
                    var tempX = 0
                    var tempY = 0
                    
                    var pointsArray = [CGPoint]()
                    var classification = 0
                    for column in objectColumns {
                        if (columnIndex == 16) {
                            guard let classificationNumber = Int(column.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) else { continue }
                            classification = classificationNumber
                            continue
                        }
                        if (columnIndex % 2 == 0) {
                            guard let x = Int(column.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) else { continue }
                            tempX = x
                        } else {
                            guard let y = Int(column.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) else { continue }
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
