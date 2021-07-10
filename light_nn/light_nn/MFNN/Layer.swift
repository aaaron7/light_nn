//
//  Layers.swift
//  light_nn
//
//  Created by aaron on 2021/6/26.
//

import Foundation

class Layer {
    var neurons : [Neuron] = []
    var prevLayer : Layer?
    var nextLayer : Layer?
    init(neuronConut : Int, prevL : Layer?) {
        prevLayer = prevL
        for _ in 0...neuronConut-1{
            let n = Neuron()
            if let pl = prevLayer{
                n.inputWeights = [Double](repeating: 0, count: pl.neurons.count)
                n.makeWeightsRandom()
            }
            neurons.append(n)
        }
    }
    
    func getOutputs(input:[Double])->[Double]{
        if prevLayer != nil{
            return neurons.map { n in
                n.getOutputs(input: input)
            }
        } else {
            for i in (1..<neurons.count){
                neurons[i].s = input[i] 
            }
            return input
        }
    }
}
