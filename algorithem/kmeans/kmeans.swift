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

enum KMeansError: Error {
    case noDimension
    case noClusteringNumber
    case noVectors
    case clusteringNumberLargerThanVectorsNumber
    case otherReason(String)
}

class KMeansSwift {
    
    static let sharedInstance = KMeansSwift()
    fileprivate init() {}
    
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
    var vectors = Matrix()
    //final centroids
    var finalCentroids = Matrix()
    //final clusters
    var finalClusters = Array<Matrix>()
    //temp centroids
    fileprivate var centroids = Matrix()
    //temp clusters
    fileprivate var clusters = Array<Matrix>()
    
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
    func addVector(_ newVector:Vector) {
        vectors.append(newVector)
    }
    
    func addVectors(_ newVectors:Matrix) {
        for newVector:Vector in newVectors {
            addVector(newVector)
        }
    }
    
    //clustering
    func clustering(_ numberOfExcutions:Int, completion:(_ success:Bool, _ centroids:Matrix, _ clusters:[Matrix])->()) {
        beginClusteringWithNumberOfExcution(numberOfExcutions)
        return completion(true, finalCentroids, finalClusters)
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
    fileprivate func pickingInitialCentroidsRandomly() {
        let indexes = vectors.count.indexRandom[0..<clusteringNumber]
        var initialCenters = Matrix()
        for index:Int in indexes {
            initialCenters.append(vectors[index])
        }
        centroids = initialCenters
    }
    
    // 2: assign each vector to the group that has the closest centroid.
    fileprivate func assignVectorsToTheGroup() {
        clusters.removeAll()
        for _ in 0..<clusteringNumber {
            clusters.append([])
        }
        for vector in vectors{
            var tempDistance = -1.0
            var groupNumber = 0
            for index in 0..<clusteringNumber {
                if tempDistance == -1.0 {
                    tempDistance = euclideanDistance(vec1: vector, vec2: centroids[index])
                    groupNumber = index
                    continue
                }
                if euclideanDistance(vec1: vector, vec2: centroids[index]) < tempDistance {
                    groupNumber = index
                }
            }
            clusters[groupNumber].append(vector)
        }
    }
    
    // 3: recalculate the positions of the K centroids. (return move distance square)
    fileprivate func recalculateCentroids() -> Double {
        var moveDistanceSquare = 0.0
        for index in 0..<clusteringNumber {
            var newCentroid = Vector(repeating: 0.0, count: dimension)
            let vectorSum = clusters[index].reduce(newCentroid, { vecAdd(vec1: $0, vec2: $1) })
            var s = Double(clusters[index].count)
            vDSP_vsdivD(vectorSum, 1, &s, &newCentroid, 1, vDSP_Length(vectorSum.count))
            if moveDistanceSquare < euclideanDistance(vec1: centroids[index], vec2: newCentroid) {
                moveDistanceSquare = euclideanDistance(vec1: centroids[index], vec2: newCentroid)
            }
            centroids[index] = newCentroid
        }
        return moveDistanceSquare
    }
    
    // 4: repeat 2,3 until the new centroids cannot move larger than convergenceError or the iteration is over than maxIteration
    fileprivate func beginClustering() -> Double {
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
    fileprivate func costFunction() -> Double {
        var cost = 0.0
        for index in 0..<clusteringNumber {
            for vector in clusters[index] {
                cost += euclideanDistance(vec1: vector, vec2: centroids[index])
            }
        }
        return cost
    }
    
    // 5: excute again (up to the number of excution), then choose the best result
    private func beginClusteringWithNumberOfExcution(_ number:Int) {
        var number = number
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

