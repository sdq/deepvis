//
//  vector.swift
//  deepvis
//
//  Created by sdq on 8/15/17.
//  Copyright © 2017 sdq. All rights reserved.
//

import Foundation
import Accelerate

typealias Vector = [Double]

// Vector Calculation
func vecAdd(vec1:Vector, vec2:Vector) -> Vector {
    var addresult = Vector(repeating: 0.0, count: vec1.count)
    vDSP_vaddD(vec1, 1, vec2, 1, &addresult, 1, vDSP_Length(vec1.count))
    return addresult
}

func vecSub(vec1:Vector, vec2:Vector) -> Vector {
    var subresult = Vector(repeating: 0.0, count: vec1.count)
    vDSP_vsubD(vec1, 1, vec2, 1, &subresult, 1, vDSP_Length(vec1.count))
    return subresult
}

func vecScale(vec:Vector, num:Double) -> Vector {
    var n = num
    var vsresult = Vector(repeating: 0.0, count: vec.count)
    vDSP_vsmulD(vec, 1, &n, &vsresult, 1, vDSP_Length(vec.count))
    return vsresult
}

func vecDot(vec1:Vector, vec2:Vector) -> Double {
    var dotresult = 0.0
    vDSP_dotprD(vec1, 1, vec2, 1, &dotresult, vDSP_Length(vec1.count))
    return dotresult
}

func vecDiv(vec1:Vector, vec2:Vector) -> Vector {
    var divresult = Vector(repeating: 0.0, count: vec1.count)
    vDSP_vdivD(vec2, 1, vec1, 1, &divresult, 1, vDSP_Length(vec1.count))
    return divresult
}

// Mean Vector
func meanVector(inputVectors:[Vector]) -> Vector {
    let vecDimension = inputVectors[0].count
    let vecCount = Double(inputVectors.count)
    let sumVec = inputVectors.reduce(Vector(repeating: 0.0, count: vecDimension),{vecAdd(vec1: $0, vec2: $1)})
    let averageVec = sumVec.map({$0/vecCount})
    return averageVec
}

// Mean Normalization
func meanNormalization(inputVectors:[Vector]) -> [Vector] {
    let averageVec = meanVector(inputVectors: inputVectors)
    let outputVectors = inputVectors.map({vecSub(vec1: $0, vec2: averageVec)})
    return outputVectors
}

// Vector Distance

func euclideanDistance(vec1:Vector, vec2:Vector) -> Double {
    let subVec = vecSub(vec1: vec1, vec2: vec2)
    var distance = 0.0
    vDSP_dotprD(subVec, 1, subVec, 1, &distance, vDSP_Length(subVec.count))
    let distanceSquare = abs(distance)
    
    // just return distanceSquare for speed
    return sqrt(distanceSquare) // or return "sqrt(distanceSquare)"
}

func manhattanDistance(vec1:Vector, vec2:Vector) -> Double {
    var distance = 0.0
    for i in 0..<vec1.count {
        let dist = vec1[i] - vec2[i]
        if dist < 0 {
            distance -= dist
        } else {
            distance += dist
        }
    }
    return distance
}
