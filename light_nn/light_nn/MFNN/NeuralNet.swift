//
//  Net.swift
//  light_nn
//
//  Created by aaron on 2021/6/26.
//

import Foundation
import Accelerate

class NeuralNet {
    var layers : [Layer] = []
    var netShape : [Int] = []
    
    init(shape : [Int]) {
        netShape = shape
        let time = Int(NSDate().timeIntervalSinceReferenceDate)
        srand48(time)
        
        var prevLayer:Layer? = nil
        for item in shape{
            let layer = Layer(neuronConut: item, prevL: prevLayer)
            prevLayer?.nextLayer = layer
            prevLayer = layer
            layers.append(layer)
        }
    }
    
    func getOutputs(input: [Double]) -> [Double] {
        assert(input.count == netShape[0])
        return layers.reduce(input) { r, l in
            l.getOutputs(input: r);
        }
    }

    
    var testBlock : ((Int)->Void)?
    
    func train(inputs : [[Double]], labels : [[Double]]){
        for (loc, xs) in inputs.enumerated(){
            let ys = labels[loc]
            _ = getOutputs(input: xs)
            if loc % 500 == 0{
                if let b = testBlock{
                    b(loc)
                }
            }
            backprop(labels: ys)
            
        }
    }
    
    func backprop(labels : [Double]){
        for i in (1..<layers.count).reversed(){
            let l = layers[i]
            var truth:Double = 0.0
            for (j, neuron) in l.neurons.enumerated(){
                if l.nextLayer == nil{
                    truth = labels[j]
                }
                neuron.updateGrad(truth: truth, nextLayer: l.nextLayer, idx: j)
            }
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
