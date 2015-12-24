//
//  KMeansSwiftTests.swift
//  KMeansSwiftTests
//
//  Created by sdq on 15/12/22.
//  Copyright © 2015年 sdq. All rights reserved.
//

import XCTest
@testable import KMeansSwift

class KMeansSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test2DClustering() {
        
        let v1 = [2.0, 3.0]
        let v2 = [3.0, 2.0]
        let v3 = [9.0, 10.0]
        let v4 = [10.0, 9.0]
        let v5 = [7.0, 8.0]
        let v6 = [3.0, 3.0]
        let v7 = [13.0, 12.0]
        let v8 = [0.0, 1.0]
        
        let instance = KMeansSwift.sharedInstance
        instance.addVectors([v1, v2, v3, v4, v5, v6, v7, v8])
        instance.clustering(10) { (success, centroids, clusters) -> () in
            if success {
                print("====centroids====")
                print(centroids)
                print("====clusters====")
                print(clusters)
                
                XCTAssert(centroids == [[9.75, 9.75], [2.0, 2.25]] || centroids == [[2.0, 2.25], [9.75, 9.75]], "wrong centroids")
                XCTAssert(clusters == [[v1, v2, v6, v8], [v3, v4, v5, v7]] || clusters == [[v3, v4, v5, v7], [v1, v2, v6, v8]], "wrong clusters")
                
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
