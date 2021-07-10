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
    init(neuronConut : Int, prevL : Layer?, bias : Bool) {
        prevLayer = prevL
        for _ in 0...neuronConut-1{
            let n = Neuron()
            if let pl = prevLayer{
                for _ in 0...pl.neurons.count-1{
                    n.inputWeights.append(0)
                }
                n.makeWeightsRandom()
            }
            neurons.append(n)
        }
        
        if bias{
            let n = BiasNeuron()
            if let pl = prevLayer{
                for _ in 0...pl.neurons.count-1{
                    n.inputWeights.append(0)
                }
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
    
    func updateDerivative(labels : [Double]){
        for (i, neuron) in neurons.enumerated(){
            var truth:Double = 0.0
            if nextLayer == nil{
                truth = labels[i]
            }
            
            neuron.updateDerivative(truth: truth, nextLayer: nextLayer, idx: i)
        }
    }
}
