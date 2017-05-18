# KMeansSwift

This is a unsupervised machine learning algorithm K-means realized by Swift

It can be used in N-dimensional space!

You can download and play with the demo from [App Store](https://itunes.apple.com/us/app/k-means-an-unsupervised-machine-learning-algorithm/id1070820122)

Demo
------
![demo](https://github.com/sdq/kmeans.swift/blob/master/demo.gif)
[App Store](https://itunes.apple.com/us/app/k-means-an-unsupervised-machine-learning-algorithm/id1070820122)


How to use
------
Just drag the kmeans.swift into your project.

```
let KMeans = KMeansSwift.sharedInstance
KMeans.clusteringNumber = 2
KMeans.clustering(500) { [unowned self] (success, centroids, clusters) -> () in
    ....
}
```

Similar projects
------
[pca.swift](https://github.com/sdq/pca.swift)

Author
------
[sdq](http://shidanqing.net)

License
-------
[MIT](https://opensource.org/licenses/MIT)
