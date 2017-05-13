# KMeansSwift

This is a unsupervised machine learning algorithm K-means realized by Swift

It can be used in N-dimensional space!

Demo
------
![demo](https://github.com/sdq/KMeansSwift/blob/master/demo.gif)

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

Author
------
[sdq](http://shidanqing.net)


License
-------
[MIT](https://opensource.org/licenses/MIT)
