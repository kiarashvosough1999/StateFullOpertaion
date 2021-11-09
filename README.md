# StateFullOpertaion

[![Swift](https://img.shields.io/badge/Swift-5.3_or_Higher-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.1_5.2_5.3_5.4-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_9_or_Higher-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_Linux_Windows-Green?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Alamofire.svg?style=flat-square)](https://img.shields.io/cocoapods/v/Alamofire.svg)
[![Twitter](https://img.shields.io/badge/twitter-@Vosough_k-blue.svg?style=flat-square)](https://twitter.com/AlamofireSF)
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Unleash the power of Operation with StateFullOpertaion

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [SampleProjects](#Sample)
- [Usage](#Usage)
- [Contributors](#Contributors)
- [License](#license)

## Requirements

| Platform | Minimum Swift Version | Installation | Status |
| --- | --- | --- | --- |
| iOS 9.0+ | 5.3 | [CocoaPods](#cocoapods) | Tested |

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate StateFullOpertaion into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'StateFullOpertaion'
```

## Sample

I have provided one sample project in the repository. To use it clone the repo, Source files for these are in the `Example` directory in project navigator. Have fun!

##Usage


###SafeOperation

SafeOperation is a convinient way of using operation.
It offers new features which the operation itself does not support or could be so tricky to use.

> Subclasses must not override any method of the base Opertaion Class or call them
 , instead they can override the provided method on protocol `OperationLifeCycleProvider` to take control of what should be done.
 
> `enqueueSelf` can be use to add operation to a Queue, just make sure you provide operation a queue within its initializer.

#### Subclassing
 
 ```swift
 class MyOperation: SafeOperation {
    
    override func shouldStartRunnable() throws {
        try super.shouldStartRunnable()
        /// do some pre-requireties before the runnable start
    }
    
    override func runnable() throws {
        /// impelement your task here
        /// call `cancelRunnable()` whenever the task finish
    }
    
    override func finishRunnable() throws {
        try finishRunnable()
        /// make sure you call `finishRunnable()`
    }
    
    override func didFinishRunnable() {
        // this method will be called sync-ly after runnable retured
        // if `runnable()` overrided, after it is finished,
        // `super.runnable()` can be called to run `didFinishRunnable()`
        // this method will be also called after calling `finishRunnable()`
        // do whatever after the runnable finished
    }
    
    override func cancelRunnable() throws {
        try super.cancelRunnable()
        /// make sure you call `super.cancelRunnable()` in order to change operation flag
    }
    
    override func didCancelRunnable() {
        /// after operation canceled and before the operation is poped from queue this method will be called
    }
}
 ```

#### Closure

you may want to add operation with out all feature it provide with subclassing, using new method on OperationQueue can become handy.

```swift

let queue = OperationQueue()

queue.addOperation(identifier: .unique(), queuePriority: .normal, qualityOfService: .background) { completed in
   // your code
	
   // after you've done the completed block should be called to dequeue operation from queue
   ompleted()
	
} onCompleted: {
   // will be call just right before the dequeing operation from queue
} onCanceled: {
   // called when `cancelRunnable()` is called
} onFinished: {
   // called when `completed()` is called inside operation block
} onExecuting: {
   // called when opertion is enqued and started
}

```


## Contributors

Feel free to share your ideas or any other problems. Pull requests are welcomed.

## License

CocoAttributedStringBuilder is released under an MIT license. See [LICENSE](https://github.com/kiarashvosough1999/StateFullOpertaion/blob/master/LICENSE) for more information.
