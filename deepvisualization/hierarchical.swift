//
//  hierarchicalClustering.swift
//  deepvis
//
//  Created by sdq on 8/15/17.
//  Copyright © 2017 sdq. All rights reserved.
//

import Foundation
import Accelerate

class HierarchicalClustering {
    
    static let sharedInstance = HierarchicalClustering()
    fileprivate init() {}
    
    //clustering number K
    var k:Int = 2
    //vectors
    var vectors:[Vector] = []
    
    //MARK: Public
    
    //check parameters
    func checkAllParameters() -> Bool {
        if k < 1 { return false }
        if vectors.count < k { return false }
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
    
    func reset() {
        vectors.removeAll()
    }
    
    func hierarchicalClustering(completion:(_ success:Bool, _ distMat:Matrix, _ clusters:[[Vector]])->()) {
        if vectors.count == 0 || vectors.count < k {
            return
        }
        if k == 1 {
            completion(true, [[]], [vectors])
        }
        // 1. Initialize Clusters
        var clusters: [[Vector]] = []
        for vector in vectors {
            clusters.append([vector])
        }
        // 2. Distance Matrix
        let m = vectors.count
        let zeroVec:Vector = [Double](repeating: 0.0, count: m)
        var distMat:Matrix = [Vector](repeating: zeroVec, count: m)
        for i in 0..<m {
            for j in 0..<m {
                if i != j {
                    distMat[i][j] = clusterDistance(c1: clusters[i], c2: clusters[j])
                }
            }
        }
        let initDistMat = distMat
        // 3. Clustering
        var q = m
        while q > k {
            //(1) find 2 nearest clusters
            var shortestDist = 10000.0
            var im = 0
            var jm = 1
            for i in 0..<q {
                for j in i..<q {
                    if i != j {
                        if distMat[i][j] < shortestDist {
                            shortestDist = distMat[i][j]
                            im = i
                            jm = j
                        }
                    }
                }
            }
            //(2) merge them
            clusters[im] = clusters[im] + clusters[jm]
            //(3) edit clusters
            clusters.remove(at: jm)
            //(4) edit distMat
            q -= 1
            let zeroVec:Vector = [Double](repeating: 0.0, count: q)
            distMat = [Vector](repeating: zeroVec, count: q)
            for i in 0..<q {
                for j in 0..<q {
                    if i != j {
                        distMat[i][j] = clusterDistance(c1: clusters[i], c2: clusters[j])
                    }
                }
            }
        }
        //return final clusters
        completion(true, initDistMat, clusters)
    }
    
    func hierarchicalization(completion:(_ success:Bool, _ links:[(Int,Int)])->()) {
        if vectors.count == 0 || vectors.count < k {
            return
        }
        // 1. Initialize Clusters
        var clusters: [[Vector]] = []
        for vector in vectors {
            clusters.append([vector])
        }
        let m = vectors.count
        var clusterItems: [[Int]] = []
        for i in 0..<m {
            clusterItems.append([i])
        }
        
        // 2. Distance Matrix
        let zeroVec:Vector = [Double](repeating: 0.0, count: m)
        var distMat:Matrix = [Vector](repeating: zeroVec, count: m)
        for i in 0..<m {
            for j in 0..<m {
                if i != j {
                    distMat[i][j] = clusterDistance(c1: clusters[i], c2: clusters[j])
                }
            }
        }
        var q = m
        var merged:[Int] = []
        var links:[(Int,Int)] = []
        while q > 1 {
            //(1) find 2 nearest clusters
            var shortestDist = 10000.0
            var im = 0
            var jm = 1
            for i in 0..<m {
                if merged.contains(i) {
                    continue
                }
                for j in i..<m {
                    if merged.contains(j) {
                        continue
                    }
                    if i != j {
                        if distMat[i][j] < shortestDist {
                            shortestDist = distMat[i][j]
                            im = i
                            jm = j
                        }
                    }
                }
            }
            //(2) merge them
            let clusterim = meanVector(inputVectors: clusters[im])
            let clusterjm = meanVector(inputVectors: clusters[jm])
            var mindist = 10000.0
            var imm = clusterItems[im][0]
            var jmm = clusterItems[jm][0]
            for ii in clusterItems[im] {
                let newDistance = euclideanDistance(vec1: vectors[ii], vec2: clusterim)
                if newDistance < mindist {
                    imm = ii
                    mindist = newDistance
                }
            }
            mindist = 10000.0
            for jj in clusterItems[jm] {
                let newDistance = euclideanDistance(vec1: vectors[jj], vec2: clusterjm)
                if newDistance < mindist {
                    jmm = jj
                }
            }
            links.append((imm,jmm))
            
            clusters[im] = clusters[im] + clusters[jm]
            clusterItems[im] = clusterItems[im] + clusterItems[jm]
            merged.append(jm)
            
            
            q -= 1
            let zeroVec:Vector = [Double](repeating: 0.0, count: m)
            distMat = [Vector](repeating: zeroVec, count: m)
            for i in 0..<m {
                if merged.contains(i) {
                    continue
                }
                for j in 0..<m {
                    if merged.contains(j) {
                        continue
                    }
                    if i != j {
                        distMat[i][j] = clusterDistance(c1: clusters[i], c2: clusters[j])
                    }
                }
            }
            completion(true, links)
        }
        
    }
    
    func clusterDistance(c1:[Vector], c2:[Vector]) -> Double {
        let c1v = meanVector(inputVectors: c1)
        let c2v = meanVector(inputVectors: c2)
        return euclideanDistance(vec1: c1v, vec2: c2v)
    }
}
