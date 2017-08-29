//
//  lda.swift
//  deepvis
//
//  Created by sdq on 8/5/17.
//  Copyright © 2017 sdq. All rights reserved.
//

import Foundation

class LDA {
    static let sharedInstance = LDA()
    fileprivate init() {}
    
    func dimensionReduction(inputMats:[Matrix], dimention:Int, completion:(_ success:Bool, _ outputMatrixs:[Matrix], _ reduceMat:Matrix)->()) {
        let classCount = inputMats.count
        if dimention >= classCount {
            print("Dimension cannot be larger than (classCount-1)")
        }
        let n = inputMats[0][0].count
        let zeroMat:Matrix = Matrix(repeating: Vector(repeating: 0.0, count: n), count: n)
        
        // 1. 计算每个分类的均值向量, 矩阵均值化
        var meanMats:[Matrix] = []
        for inputMat in inputMats {
            meanMats.append(meanNormalization(inputVectors: inputMat))
        }
        
        // 2. 计算散列矩阵
        var scatterMats:[Matrix] = []
        for meanMat in meanMats {
            scatterMats.append(covarianceMatrix(inputMatrix: meanMat))
        }
        let sw = scatterMats.reduce(zeroMat, {matAdd(mat1: $0, mat2: $1)})
        
        let wholeMatrix = inputMats.reduce([], {$0+$1})
        let meanVecs = inputMats.map({meanVector(inputVectors: $0)})
        let mean = meanVector(inputVectors: wholeMatrix)
        
        var meanCenters = meanVecs.map({vecSub(vec1: $0, vec2: mean)})
        var ss:[Matrix] = []
        for i in 0..<classCount {
            ss.append(matScale(mat: matMul(mat1: [meanCenters[i]], mat2: transpose(inputMatrix: [meanCenters[i]])), num: Double(inputMats[i].count)))
        }
        let sb:Matrix = ss.reduce(zeroMat, {matAdd(mat1: $0, mat2: $1)})
        
        // 3. 计算特征值与特征向量
        guard let inv = invert(inputMatrix: sw) else {
            return
        }
        let swsb = matMul(mat1: inv, mat2: sb)
        
        let (eigenvalues, eigenvectors) = ev(inputMatrix: swsb)
        
        //sort eigenvectors
        var evvs:[(Double,Vector)] = []
        for i in 0..<n {
            evvs.append((eigenvalues[i], eigenvectors[i]))
        }
        evvs = evvs.sorted(by: {$0.0>$1.0})
        
        let sortedEigenvectors = evvs.map({$0.1})
        let reduceMat = reduceMatrix(inputMatrix: sortedEigenvectors, k: dimention)
        
        let newMats = inputMats.map({reduce(inputMatrix: $0, reduceMatrix: reduceMat)})
        
        completion(true, newMats, reduceMat)
    }
    
    fileprivate func reduceMatrix(inputMatrix:Matrix, k:Int) -> Matrix {
        if k >= inputMatrix.count {
            return inputMatrix
        }
        return Array(inputMatrix[0..<k])
    }
    
    fileprivate func reduce(inputMatrix:Matrix, reduceMatrix:Matrix) -> Matrix {
        if reduceMatrix[0].count != inputMatrix[0].count {
            return [[]]
        }
        let t = transpose(inputMatrix: reduceMatrix)
        return matMul(mat1: t, mat2: inputMatrix)
    }
}
