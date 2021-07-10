//
//  Utility.swift
//  light_nn
//
//  Created by aaron on 2021/7/1.
//

import Foundation


class MNISTDataSet{
    var trainImages = [[UInt8]]()
    var trainLabels = [UInt8]()
    var testImages = [[UInt8]]()
    var testLabels = [UInt8]()
    
    init() {
        
    }
    
    func load(){
    
        trainImages = loadImages(fileName: "train-images")
        testImages = loadImages(fileName: "t10k-images")
        trainLabels = loadLabels(fileName: "train-labels")
        testLabels = loadLabels(fileName: "t10k-labels")
    }
    
    func loadImages(fileName : String) -> [[UInt8]]{
        var result = [[UInt8]]()
        if let path = Bundle.main.path(forResource: fileName, ofType: "idx3-ubyte"){
            if let stream = InputStream(fileAtPath: path){
                defer {
                    stream.close()
                }
                stream.open()
                var empty = [UInt8](repeating: 0, count: 16)
                stream.read(&empty, maxLength: 16)
                var image = [UInt8](repeating: 0, count: 784)
                while stream.read(&image, maxLength: 784) == 784 {
                    result.append(image)
                }
            }
        }
        return result
    }
    
    func loadLabels(fileName : String) -> [UInt8]{
        var result = [UInt8]()
        if let path = Bundle.main.path(forResource: fileName, ofType: "idx1-ubyte"){
            if let stream = InputStream(fileAtPath: path){
                stream.open()
                defer {
                    stream.close()
                }
                
                stream.open()
                var empty = [UInt8](repeating: 0, count: 8)
                stream.read(&empty, maxLength: 8)
                var label: UInt8 = 0
                while stream.read(&label, maxLength: 1) == 1 {
                    result.append(label)
                }
            }
        }
        return result
    }
    
    func regularizationImage() -> [[Double]]{
        return trainImages.map{$0.map{Double($0) / 255}}
    }
    
    func regularizationLabel() -> [[Double]]{
        return trainLabels.map { label in
            var result = [Double](repeating: 0.0, count: 10)
            result[Int(label)] = 1.0
            return result
        }
    }
    
}
