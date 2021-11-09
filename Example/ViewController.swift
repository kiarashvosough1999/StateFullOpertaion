//
//  ViewController.swift
//  Example
//
//  Created by Kiarash Vosough on 8/16/1400 AP.
//

import UIKit
import StateFullOperation

class ViewController: UIViewController {

    let queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do {
            let op = MyOperation(operationQueue: queue, configuration: .init())
            op.setOperationCompletedSignal {
                print(self.queue.operationCount)
            }
            try op.enqueueSelf()
            DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                print(self.queue.operationCount)
            }
        } catch {
            print(error)
        }
    }


}


class MyOperation: SafeOperation {
   
   override func shouldStartRunnable() throws {
       try super.shouldStartRunnable()
       /// do some pre-requireties before the runnable start
   }
   
   override func runnable() throws {
       /// impelement your task here
       /// call `cancelRunnable()` whenever the task finish
       print("start")
       let sDate = Date()
       Thread.sleep(forTimeInterval: 5)
       let eDate = Date()
       print("end", eDate.timeIntervalSince(sDate))
       try finishRunnable()
   }
   
   override func cancelRunnable() throws {
       try super.cancelRunnable()
       /// make sure you call `super.cancelRunnable()` in order to change operation flag
   }
   
   override func didCancelRunnable() {
       /// after operation canceled and before the operation is poped from queue this method will be called
   }
}
