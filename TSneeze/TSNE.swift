//
//  TSNE.swift
//  TSneeze
//
//  Created by Brian Ledbetter on 6/20/16.
//  Copyright © 2016 Brian Ledbetter. All rights reserved.
//

import Foundation

class TSNE{
    var epsilon : Int
    var perplexity : Int
    var dimensionality : Int
    var similarityMatrix :[[Double]]?
    var tol = pow(1 * M_E, -4)
    
    var pVector : [Double]?
    var X : HighDimensionalSet?
    var P : [Double]?
    var N : Int?
    
    var gains : [[Double]]?
    var ystep : [[Double]]?
    var Y : [[Double]]? //aka the current answer (evolves iteratively)
    
    var cachedGaussRandom : Double?
    
    // which step we are on in calculation
    var iter = 0
    
    /*
     High Dimensional Data Sets may include HighDItems which have sigmas.
     epsilon is learning rate (10 = recommended default)
     roughly how many neighbors each point influences (30 = recommended default)
     Perplexity should decrease as sigma decreases (the model fits better)
    */
    
    init(learningRate : Int, perplexity : Int, dimensionality : Int, X : HighDimensionalSet) {
        print("Initialized with High Dimensional Data Set")
        self.epsilon = learningRate
        self.perplexity = perplexity
        self.dimensionality = dimensionality
        
        
        // begin solution
        self.gains = multiDVectorArray(X.comparables.count, fill: 1.0, dimensions: self.dimensionality)
        self.ystep = multiDVectorArray(X.comparables.count, fill: 0.0, dimensions: self.dimensionality) // momentum accelerator

        self.X = X
        self.N = X.comparables.count

        let distancesAndSigma = x2D(X)
        
        print("Finished creating Distances")
        if (distancesAndSigma.1 == nil) {
            // if no sigmas are passed in, calculate our own based on perplexity
            self.P = d2p(distancesAndSigma.0, sigmas: distancesAndSigma.1)
        } else {
            // we have sigmas
            debug("Initialized with sigmas but sigmas are not handled yet.")
        }
        self.Y = self.randomVectorArray(X.comparables.count)
    }
    /*
     MARK: STEP
     This function is T-SNE's iterative improvement method.  Every step will improve the solution slightly.  A reasonable number of steps
     is about 500.
     Data input: An N by N matrix of values.  This matrix is the similarity matrix, it shows how close each data point d is to every other data point in the high-dimensional set.   
    */
    func step(_ stepNumber : Int, stepTotal: Int) -> Double? {
        guard let cg = costGradient(self.Y!) else { debug("Failed to step because of failed cost gradient."); return nil }
        let cost = cg.0
        let grad = cg.1

        // perform gradient step
        var ymean = vectorArray(self.dimensionality, fill: 0.0)
        for i in 0 ..< self.N! {
            for d in 0 ..< self.dimensionality {
                let gid = grad[i][d]
                let sid = self.ystep![i][d]
                let gainid = self.gains![i][d]
                
                // compute gain update
                var newgain = sign(gid) == sign(sid) ? gainid * 0.8 : gainid + 0.2
                if (newgain < 0.01) {
                    newgain = 0.01 //clamp
                }
                self.gains![i][d] = newgain; // store for next turn
                
                // compute momentum step direction
                let momval = Double(stepNumber) < (0.5 * Double(stepTotal)) ? 0.5 : 0.8;
                let newsid = momval * sid - Double(self.epsilon) * newgain * grad[i][d];
                self.ystep![i][d] = newsid; // remember the step we took
                
                // step!
                self.Y![i][d] += newsid;
                ymean[d] += self.Y![i][d]; // accumulate mean so that we can center later
            }
        }
        // reproject Y to be zero mean
        for i in 0 ..< self.N! {
            for d in 0 ..< self.dimensionality {
                self.Y![i][d] -= ymean[d]/Double(self.N!)
            }
        }
        return cost // return current cost
    }
    /*
     MARK: GET SOLUTION
     */
    func getSolution(_ steps: Int, plotData: ([[Double]]?) ->()) {
        
        for x in 0 ..< steps {
            step(x, stepTotal: steps)
//            print("Step \(x + 1) of \(steps), cost is: \(step(x, stepTotal: steps))")
        }
        var coordinates = [[Double]]()
        for row in self.Y! {
            coordinates.append([row[0], row[1]])
        }
        plotData(coordinates)
    }
    
    // Get solution iteratively (when the user wants to see each step.)
    func iterateSolution(_ plotData: ([[Double]]) -> ()) {
        step(1, stepTotal: 1)
        
        var coordinates = [[Double]]()
        for row in self.Y! {
            coordinates.append([row[0], row[1]])
        }
        plotData(coordinates)

//        for i in 0 ..< self.Y!.count {
//            xValues.append("\(self.Y![i][0])")
//            let point = ChartDataEntry(value: Double(self.Y![i][1]), xIndex: i)
//            if let classification = self.X!.classifications?[i] {
//                if (dataSets[classification] != nil) {
//                    dataSets[classification]!.append(point)
//                } else {
//                    dataSets.updateValue([point], forKey: classification)
//                }
//            }
//        }
//        
//        var scatterChartPlotData = [ScatterChartDataSet]()
//        for (key, value) in dataSets {
//            let classifiedChartData = ScatterChartDataSet(yVals: value, label: key)
//            classifiedChartData.scatterShape = ScatterChartDataSet.ScatterShape.Circle
//            
//            let red = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
//            let blue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
//            let green = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
//
//            classifiedChartData.setColor(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
//            scatterChartPlotData.append(classifiedChartData)
//        }
//        
//        plotData(ScatterChartData(xVals: xValues, dataSets: scatterChartPlotData))
    }
    
    
    // the first step of T-SNE (randomized)
    func initializeSolution() -> [[Double]]? {
        guard let dataSetSize = self.N else { debug("Attempting to create solution when data is not set."); return nil }
        return randomVectorArray(dataSetSize) // the solution, which starts as random
    }

    /*
     MARK: DEBUG (Make more useful later)
     */
    func debug(_ errorText : String) {
        print(errorText)
    }
    
    /*
     Helper Functions
     */
    // return 0 mean unit standard deviation random number
    func gaussRandom() -> Double {
        if let setRandom = cachedGaussRandom {
            return setRandom
        }
        let u = 2 * arc4random()-1
        let v = 2 * arc4random()-1
        let r = u*u + v*v
        if (r == 0 || r > 1) {
            return gaussRandom()
        }
        let doubleR = Double(r)
        let c = sqrt(-2 * log(doubleR)/doubleR)
        self.cachedGaussRandom = Double(v)*c
        return Double(u) * c
    }
    
    // return random normal number
    func randn(_ mu : Double, std : Double) -> Double {
        return mu + (gaussRandom() * std)
    }
    
    func sign(_ x : Double) -> Double {
        return x > 0.0 ? 1.0 : x < 0.0 ? -1.0 : 0.0
    }

    
    // utility that creates contiguous vector of numbers(the fill value) of size n
    func vectorArray(_ size : Int, fill: Double) -> [Double] {
        return [Double](repeating: fill, count: size)
    }
    
    // utility that creates 2D array numbers(the fill value) of size n
    func multiDVectorArray(_ size : Int, fill: Double, dimensions: Int) -> [[Double]] {
        var arrayToReturn = [[Double]]()
        for _ in 0 ..< size {
            for _ in 0 ..< dimensions {
                arrayToReturn.append([Double](repeating: fill, count: size))
            }
        }
        return arrayToReturn
    }

    
    // utility that returns an n-dimensioned array filled with random numbers, where n is the dimensionality of this t-sne.
    func randomVectorArray(_ size : Int) -> [[Double]] {
        var randomArray = [[Double]]()
        for _ in 0 ..< size {
            var interiorArray = [Double]()
            for _ in 0 ..< self.dimensionality {
                interiorArray.append(Double(arc4random()))
            }
            randomArray.append(interiorArray)
        }
        return randomArray
    }
    
    // compute L2 / euclidean linear distance between two vectors
    func linearDistance(_ vector1 : [Double], vector2 : [Double]) -> Double {
        var distance = 0.0
        for i in 0..<vector1.count {
            distance += (vector1[i] - vector2[i]) * (vector1[i] - vector2[i])
        }
        return distance
    }
    
    
    func x2D(_ X : HighDimensionalSet) -> ([Double], [Double]?) {
        return HighDimensionalSet.convertToDistancesVectors(X.comparables)
    }
    
    func distancesVector2ProbabilityVector(_ distances : [Double], sigmas : [Double]?) -> [Double]? {
        return d2p(distances, sigmas: sigmas)
    }
    // compute pairwise distance in all vectors in X
    func convertToSimilarityMatrix(_ multiDimensionalDataAsVectors : [[Double]]) -> [Double] {
        var distanceVector = vectorArray((multiDimensionalDataAsVectors.count * multiDimensionalDataAsVectors.count), fill: 0.0)
        for i in 0 ..< multiDimensionalDataAsVectors.count {
            for j in i+1 ..< multiDimensionalDataAsVectors.count {
                let d = linearDistance(multiDimensionalDataAsVectors[i], vector2: multiDimensionalDataAsVectors[j])
                distanceVector[(i*multiDimensionalDataAsVectors.count+j)] = d
                distanceVector[(j*multiDimensionalDataAsVectors.count+i)] = d
            }
        }
        return distanceVector
    }
    
    //MARK: compute Distance vectors into probability vectors  (p_{i|j} + p_{j|i})/(2n)
    func d2p(_ distances : [Double], sigmas : [Double]?) -> [Double]? {
        
        let nf = sqrt(Double(distances.count))
        print("Computing distances of length: \(distances.count) to P vector")
        // nf must be an integer, distances vector must have a square number of elements
        if (nf != floor(nf)) { debug("In TSNE D2P Function, the distances vector did not have a square number of elements."); return nil }
        let N = Int(nf)
        
        var Pout = vectorArray(N * N, fill: 0.0)
        if let validSigmas = sigmas {
            
//            let sigma = 4.0
//            let e = M_E
//            
//            for distance in distanceArray {
//                probabilities.append(pow(distance, 2) / pow(e, (2 * pow(sigma, 2))))
//            }
//            
//            let logSum = probabilities.reduce(0,combine: +)

        } else {
            //target entropy of the returned distribution
            let entropyTarget = log(Double(self.perplexity))
            
            // a temporary probability matrix
            var P = vectorArray(N * N, fill: 0.0)
            
            // for storage of temp variables
            var prow = vectorArray(N, fill: 0.0)
            for i in 0 ..< N {
                var done = false
                
                // auto calculate a sigma value if none is provided
                var betamin = Double(Int.min)
                var betamax = Double(Int.max)
                var beta = 1.0
                let maxtries = 50
                var numTries = 0
                while(!done) {
                    // compute entropy and kernel row with beta precision
                    var psum = 0.0
                    for j in 0 ..< Int(nf) {
                        var pj = pow(M_E, ((-1 * (distances[i * N + j] * beta))))
                        if (i == j) { pj = 0 }
                        prow[j] = pj
                        psum += pj
                    }
                    // normalize p and compute entropy
                    var Hhere = 0.0
                    for j in 0 ..< N {
                        let pj = prow[j] / psum
                        prow[j] = pj
                        if(pj > 1e-7) {
                            Hhere -= pj * log(pj)
                        }
                    }
                    // adjust beta based on result
                    if(Hhere > entropyTarget) {
                        // entropy was too high (distribution too diffuse)
                        // so we need to increase the precision for more peaky distribution
                        betamin = beta; // move up the bounds
                        if(betamax == Double(Int.max)) { beta = beta * 2 }
                        else { beta = (beta + betamax) / 2 }
                        
                    } else {
                        // converse case. make distrubtion less peaky
                        betamax = beta
                        if(betamin == Double(Int.min)) { beta = beta / 2; }
                        else { beta = (beta + betamin) / 2; }
                    }
                    
                    // stopping conditions: too many tries or got a good precision
                    numTries += 1
                    if(abs(Hhere - entropyTarget) < self.tol) { done = true; }
                    if(numTries >= maxtries) { done = true; }
                }
                // copy over the final prow to P at row i
                for j in 0 ..< N {
                    P[i*N+j] = prow[j]
                }
            } // end 'i' interator
            // symmetrize P and normalize it to sum to 1 over all ij
            let N2 = nf*2;
            for i in 0 ..< N {
                for j in 0 ..< N {
                    // place the larger of the two: (P[i*N+j] + P[j*N+i])/N2) or 1e-100
                    Pout[i*N+j] = (P[i*N+j] + P[j*N+i])/N2 > 1e-100 ? (P[i*N+j] + P[j*N+i])/N2 : 1e-100
                }
            }
        }
        
        return Pout;
    }
    // return cost and gradient of a given arrangement as a tuple
    func costGradient(_ Y : [[Double]]) -> (Double, [[Double]])? {
        guard let N = self.N else { debug("Attempting to perform cost gradients without data."); return nil }
        guard let P = self.P else { debug("Attempting to perform cost gradients without data."); return nil }
        // a trick to help with local optima
        let pmul = self.iter < 100 ? 4.0 : 1.0
        // compute current Q distribution, unnormalized first
        var Qu = vectorArray(N * N, fill: 0.0)
        var qsum = 0.0
        for i in 0 ..< N {
            for j in 0 ..< N {
                var dsum = 0.0
                for d in 0 ..< self.dimensionality {
                    let dhere = Y[i][d] - Y [j][d]
                    dsum += dhere * dhere
                }
                let qu = 1.0 / (1.0 + dsum) // Student t-distribution
                Qu[i*N+j] = qu
                Qu[j*N+i] = qu
                qsum += 2*qu
            }
        }
        // normalize Q distribution to sum to 1
        let NN = N*N
        var Q = vectorArray(NN, fill: 0.0)
        for q in 0 ..< NN { Q[q] = ((Qu[q] / qsum) > 1e-100) ? (Qu[q] / qsum) : 1e-100 }
        
        var cost = 0.0
        var grad = [[Double]]()
        for i in 0 ..< N {
            var gsum = vectorArray(self.dimensionality, fill: 0.0)
            for j in 0 ..< N {
                cost += -P[i*N+j] * log(Q[i*N+j]) // accumulate cost (the non-constant portion at least...)
                let premult = 4 * (pmul * P[i*N+j] - Q[i*N+j]) * Qu[i*N+j]
                for d in 0 ..< self.dimensionality {
                    gsum[d] += premult * (Y[i][d] - Y[j][d])
                }
            }
            grad.append(gsum)
        }
        return (cost, grad)
    }


}
