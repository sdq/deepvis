//
//  ViewController.swift
//  KMeansSwift
//
//  Created by sdq on 15/12/22.
//  Copyright © 2015年 sdq. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var spaceView: UIView!
    @IBOutlet weak var clusterButton1: UIButton!
    @IBOutlet weak var clusterButton2: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    let KMeans = KMeansSwift.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapSpaceView(_:)))
        spaceView.addGestureRecognizer(tapGesture)
        spaceView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    @IBAction func start3Clustering(_ sender: UIButton) {
        if KMeans.vectors.count < 3 {
            return
        }
        setButtonEnable(false)
        KMeans.clusteringNumber = 3
        KMeans.clustering(500) { [unowned self] (success, centroids, clusters) -> () in
            if success {
                for point:UIView in self.spaceView.subviews {
                    point.removeFromSuperview()
                }
                for index in 0...2 {
                    for vector in clusters[index] {
                        let pointFrame = CGRect(x: CGFloat(vector[0]) - 10, y: CGFloat(vector[1]) - 10, width: 20.0, height: 20.0)
                        let point = UIImageView(frame: pointFrame)
                        if index == 0 {
                            point.image = UIImage(named: "red")
                        } else if index == 1 {
                            point.image = UIImage(named: "yellow")
                        } else {
                            point.image = UIImage(named: "green")
                        }
                        self.spaceView.addSubview(point)
                    }
                    
                    // show centroids
                    let centerFrame = CGRect(x: CGFloat(centroids[index][0]) - 6, y: CGFloat(centroids[index][1]) - 6, width: 12.0, height: 12.0)
                    let center = UIImageView(frame: centerFrame)
                    center.image = UIImage(named: "center")
                    self.spaceView.addSubview(center)
                }
            }
            self.setButtonEnable(true)
        }
    }
    
    @IBAction func start2Clustering(_ sender: UIButton) {
        if KMeans.vectors.count < 2 {
            return
        }
        setButtonEnable(false)
        KMeans.clusteringNumber = 2
        KMeans.clustering(500) { [unowned self] (success, centroids, clusters) -> () in
            if success {
                for point:UIView in self.spaceView.subviews {
                    point.removeFromSuperview()
                }
                for index in 0...1 {
                    
                    for vector in clusters[index] {
                        let pointFrame = CGRect(x: CGFloat(vector[0]) - 10, y: CGFloat(vector[1]) - 10, width: 20.0, height: 20.0)
                        let point = UIImageView(frame: pointFrame)
                        if index == 0 {
                            point.image = UIImage(named: "red")
                        } else {
                            point.image = UIImage(named: "green")
                        }
                        self.spaceView.addSubview(point)
                    }
                    
                    // show centroids
                    let centerFrame = CGRect(x: CGFloat(centroids[index][0]) - 6, y: CGFloat(centroids[index][1]) - 6, width: 12.0, height: 12.0)
                    let center = UIImageView(frame: centerFrame)
                    center.image = UIImage(named: "center")
                    self.spaceView.addSubview(center)
                }
            }
            self.setButtonEnable(true)
        }
    }
    
    @IBAction func clickGithubItem(_ sender: UIBarButtonItem) {
        let svc = SFSafariViewController(url: URL(string: "https://github.com/sdq/KMeansSwift")!)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func clickWikiItem(_ sender: UIBarButtonItem) {
        let svc = SFSafariViewController(url: URL(string: "https://en.wikipedia.org/wiki/K-means_clustering")!)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        setButtonEnable(false)
        KMeans.reset()
        for point:UIView in self.spaceView.subviews {
            point.removeFromSuperview()
        }
        setButtonEnable(true)
    }
    
    func tapSpaceView(_ recognizer:UITapGestureRecognizer) {
        let location = recognizer.location(in: spaceView)
        let pointFrame = CGRect(x: location.x - 10, y: location.y - 10, width: 20, height: 20)
        let grayPoint = UIImageView(frame: pointFrame)
        grayPoint.image = UIImage(named: "gray")
        spaceView.addSubview(grayPoint)
        KMeans.addVector([Double(location.x), Double(location.y)])
    }
    
    fileprivate func setButtonEnable(_ enable:Bool) {
        clusterButton1.isEnabled = enable
        clusterButton2.isEnabled = enable
        clearButton.isEnabled = enable
    }
    
    fileprivate func drawLine(from: CGPoint, to: CGPoint) {
        
    }

}

// MARK: SFSafariViewControllerDelegate

extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}

