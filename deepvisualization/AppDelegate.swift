//
//  AppDelegate.swift
//  deepvisualization
//
//  Created by sdq on 8/28/17.
//  Copyright © 2017 sdq. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let kmeans = KMeans.sharedInstance
        kmeans.addVectors(iris)
        kmeans.clusteringNumber = 3
        kmeans.clustering(500) { (success, centroids, clusters) in
            print("------kmeans--------")
            print("clusters")
            print(clusters)
        }
        
        
//        let hca = HierarchicalClustering.sharedInstance
//        hca.addVectors(iris)
//        hca.k = 3
//        hca.hierarchicalClustering { (success, distMat, clusters) in
//            print("------hca--------")
//            print("clusters")
//            print(clusters)
//        }
        
        
        let pca = PCA.sharedInstance
        pca.dimensionReduction(iris, dimension: 2) { (success, output, reduceMat, u, s, v) in
            print("------pca--------")
            print(output)
        }
        
//        let lda = LDA.sharedInstance
//        lda.dimensionReduction(inputMats: [setosa, versicolor, virginica], dimention: 2) { (success, output, reduce) in
//            print("------lda--------")
//            print(output)
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

