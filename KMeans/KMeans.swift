//
//  KMeans.swift
//  KMeansSwift
//
//  Created by sdq on 15/12/22.
//  Copyright © 2015年 sdq. All rights reserved.
//

import Foundation
import Accelerate
import Darwin

typealias KMVectors = Array<[Double]>
typealias KMVector = [Double]

enum KMeansError: ErrorType {
    case NoDimension
    case NoClusteringNumber
    case NoVectors
    case ClusteringNumberLargerThanVectorsNumber
    case OtherReason(String)
}

class KMeansSwift {
    
    static let sharedInstance = KMeansSwift()
    private init() {}
    
    //MARK: Parameter
    
    //dimension of every vector
    var dimension:Int = 2
    //clustering number K
    var clusteringNumber:Int = 2
    //max interation
    var maxIteration = 100
    //convergence error
    var convergenceError = 0.01
    //number of excution
    var numberOfExcution = 1
    //vectors
    var vectors = KMVectors()
    //final centroids
    var finalCentroids = KMVectors()
    //final clusters
    var finalClusters = Array<KMVectors>()
    //temp centroids
    private var centroids = KMVectors()
    //temp clusters
    private var clusters = Array<KMVectors>()
    
    //MARK: Public
    
    //check parameters
    func checkAllParameters() -> Bool {
        if dimension < 1 { return false }
        if clusteringNumber < 1 { return false }
        if maxIteration < 1 { return false }
        if numberOfExcution < 1 { return false }
        if vectors.count < clusteringNumber { return false }
        return true
    }
    
    //add vectors
    func addVector(newVector:KMVector) {
        vectors.append(newVector)
    }
    
    func addVectors(newVectors:KMVectors) {
        for newVector:KMVector in newVectors {
            addVector(newVector)
        }
    }
    
    //clustering
    func clustering(numberOfExcutions:Int, completion:(success:Bool, centroids:KMVectors, clusters:[KMVectors])->()) {
        beginClusteringWithNumberOfExcution(numberOfExcutions)
        return completion(success: true, centroids: finalCentroids, clusters: finalClusters)
    }
    
    func reset() {
        vectors.removeAll()
        centroids.removeAll()
        clusters.removeAll()
        finalCentroids.removeAll()
        finalClusters.removeAll()
    }
    
    //MARK: Private
    
    // 1: pick initial clustering centroids randomly
    private func pickingInitialCentroidsRandomly() {
        let indexes = vectors.count.indexRandom[0..<clusteringNumber]
        var initialCenters = KMVectors()
        for index:Int in indexes {
            initialCenters.append(vectors[index])
        }
        centroids = initialCenters
    }
    
    // 2: assign each vector to the group that has the closest centroid.
    private func assignVectorsToTheGroup() {
        clusters.removeAll()
        for _ in 0..<clusteringNumber {
            clusters.append([])
        }
        for vector in vectors{
            var tempDistanceSquare = -1.0
            var groupNumber = 0
            for index in 0..<clusteringNumber {
                if tempDistanceSquare == -1.0 {
                    tempDistanceSquare = EuclideanDistanceSquare(vector, v2: centroids[index])
                    groupNumber = index
                    continue
                }
                if EuclideanDistanceSquare(vector, v2: centroids[index]) < tempDistanceSquare {
                    groupNumber = index
                }
            }
            clusters[groupNumber].append(vector)
        }
    }
    
    // 3: recalculate the positions of the K centroids. (return move distance square)
    private func recalculateCentroids() -> Double {
        var moveDistanceSquare = 0.0
        for index in 0..<clusteringNumber {
            var newCentroid = KMVector(count: dimension, repeatedValue: 0.0)
            let vectorSum = clusters[index].reduce(newCentroid, combine: { vectorAddition($0, anotherVector: $1) })
            var s = Double(clusters[index].count)
            vDSP_vsdivD(vectorSum, 1, &s, &newCentroid, 1, vDSP_Length(vectorSum.count))
            if moveDistanceSquare < EuclideanDistanceSquare(centroids[index], v2: newCentroid) {
                moveDistanceSquare = EuclideanDistanceSquare(centroids[index], v2: newCentroid)
            }
            centroids[index] = newCentroid
        }
        print("=====new centers=====")
        print(centroids)
        return moveDistanceSquare
    }
    
    // 4: repeat 2,3 until the new centroids cannot move larger than convergenceError or the iteration is over than maxIteration
    private func beginClustering() -> Double {
        pickingInitialCentroidsRandomly()
        var iteration = 0
        var moveDistance = 1.0
        while iteration < maxIteration && moveDistance > convergenceError {
            iteration += 1
            assignVectorsToTheGroup()
            moveDistance = recalculateCentroids()
        }
        return costFunction()
    }
    
    // the cost function
    private func costFunction() -> Double {
        var cost = 0.0
        for index in 0..<clusteringNumber {
            for vector in clusters[index] {
                cost += EuclideanDistanceSquare(vector, v2: centroids[index])
            }
        }
        return cost
    }
    
    // 5: excute again (up to the number of excution), then choose the best result
    private func beginClusteringWithNumberOfExcution(var number:Int) {
        if number < 1 { return }
        var cost = -1.0
        while number > 0 {
            let newCost = beginClustering()
            if cost == -1.0 || cost > newCost {
                cost = newCost
                finalCentroids = centroids
                finalClusters = clusters
            }
            number -= 1
        }
    }
    
}

//MARK: Helper

//Add Vector
private func vectorAddition(vector:KMVector, anotherVector:KMVector) -> KMVector {
    var addresult = KMVector(count : vector.count, repeatedValue : 0.0)
    vDSP_vaddD(vector, 1, anotherVector, 1, &addresult, 1, vDSP_Length(vector.count))
    return addresult
}

//Calculate Euclidean Distance
private func EuclideanDistance(v1:[Double],v2:[Double]) -> Double {
    let distance = EuclideanDistanceSquare(v1,v2: v2)
    return sqrt(distance)
}

private func EuclideanDistanceSquare(v1:[Double],v2:[Double]) -> Double {
    var subVec = [Double](count : v1.count, repeatedValue : 0.0)
    vDSP_vsubD(v1, 1, v2, 1, &subVec, 1, vDSP_Length(v1.count))
    var distance = 0.0
    vDSP_dotprD(subVec, 1, subVec, 1, &distance, vDSP_Length(subVec.count))
    return abs(distance)
}

//Extension to pick random number. According to stackoverflow.com/questions/27259332/get-random-elements-from-array-in-swift
private extension Int {
    var random: Int {
        return Int(arc4random_uniform(UInt32(abs(self))))
    }
    var indexRandom: [Int] {
        return  Array(0..<self).shuffle
    }
}

private extension Array {
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count - index))) + index
            anotherIndex != index ? swap(&elements[index], &elements[anotherIndex]) : ()
        }
        return elements
    }
    mutating func shuffled() {
        self = shuffle
    }
}

