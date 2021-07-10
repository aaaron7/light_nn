//
//  Net.swift
//  light_nn
//
//  Created by aaron on 2021/6/26.
//

import Foundation
import Accelerate

class NerualNet {
    var layers : [Layer] = []
    var netShape : [Int] = []
    func getOutputs(input: [Double]) -> [Double] {
        assert(input.count == netShape[0])
        return layers.reduce(input) { r, l in
            l.getOutputs(input: r);
        }
    }
    
    init(shape : [Int]) {
        netShape = shape
        let time = Int(NSDate().timeIntervalSinceReferenceDate)
        srand48(time)
        
        var prevLayer:Layer? = nil
        var i = 0
        for item in shape{
            let layer = Layer(neuronConut: item, prevL: prevLayer, bias: false)
            prevLayer?.nextLayer = layer
            prevLayer = layer
            layers.append(layer)
            i = i+1
        }
    }
    
    var testBlock : ((Int)->Void)?
    
    func train(inputs : [[Double]], labels : [[Double]]){
        for (loc, xs) in inputs.enumerated(){

            let ys = labels[loc]
            let result = getOutputs(input: xs)
            
            let error = vecSubstract(x: ys, y: result)
            let sqr = vecMul(x: error, y: error)
            let finalError = sqrt(vecSum(x: sqr))
//            print("current error:", error)
            if loc % 500 == 0{
//                NSLog("Process: %d, error: %f", loc, finalError)
                if let b = testBlock{
                    b(loc)
                }
            }
            backprop(labels: ys)
            
        }
    }
    
    func vecSubstract(x : [Double], y: [Double]) ->[Double]{
        var result = [Double](y)
        catlas_daxpby(Int32(x.count), 1.0, x, 1, -1, &result, 1)
        return result
    }
    
    func vecMul(x : [Double], y : [Double]) -> [Double]{
        var result = [Double](repeating: 0.0, count: x.count)
        vDSP_vmulD(x, 1, y, 1, &result, 1, vDSP_Length(x.count))
        return result
    }
    
    func vecSum(x : [Double]) ->Double{
        var result : Double = 0.0
        vDSP_sveD(x, 1, &result, vDSP_Length(x.count))
        return result
    }
    
    func backprop(labels : [Double]){
        for i in (1..<layers.count).reversed(){
            layers[i].updateDerivative(labels: labels)
        }
        
        for i in (1..<layers.count){
            let l = layers[i]
            for n in l.neurons{
                n.updateWeight(prevLayer: l.prevLayer)
            }
        }
    }
    
    func export() -> [[[Double]]] {
        return layers.map { l -> [[Double]] in
            return l.neurons.map { n->[Double] in
                n.inputWeights
            }
        }
    }
}
