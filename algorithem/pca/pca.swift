import Foundation
import Accelerate

class PCA {
    static let sharedInstance = PCA()
    fileprivate init() {}
    
    // Public
    func dimensionReduction(_ inputMatrix:Matrix, dimension:Int, completion:(_ success:Bool, _ outputMatrix:Matrix, _ reduceMat:Matrix, _ u:Matrix, _ s:Matrix, _ v:Matrix)->()) {
        let meanMat = meanNormalization(inputVectors: inputMatrix)
        let covMat = covarianceMatrix(inputMatrix: meanMat)
        let (u,s,v) = svd(inputMatrix: covMat)
        let reduceMat = reduceMatrix(inputMatrix: u, k: dimension)
        let newMat = reduce(inputMatrix: meanMat, reduceMatrix: reduceMat)
        return completion(true, newMat, reduceMat, u, s, v)
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
