//
//  Neuron.swift
//  light_nn
//
//  Created by aaron on 2021/6/26.
//

import Foundation
import Accelerate

class Neuron{
    var inputWeights : [Double] = []
    var grad : Double = 0.0
    var learningRate : Double = 0.006
    var a : Double = 0.0
    var s : Double = 0.0
    
    func makeWeightsRandom(){
        inputWeights = inputWeights.map{_ in drand48() * 2 - 1}
    }
    
    func getOutputs(input : [Double]) -> Double{
        a = dotProduct(x: input, y: inputWeights)
        s = sigmoid(x: a)
        return s
    }
    
    func dotProduct(x : [Double], y : [Double]) -> Double{
        var result:Double = 0.0
        vDSP_dotprD(x, 1, y, 1, &result, vDSP_Length(x.count))
        return result
    }
    
    func sigmoid(x : Double) -> Double{
        return 1.0 / (1.0 + exp(-x))
    }
    
    func dSigmoid(x : Double) ->Double{
        let sig = sigmoid(x: x)
        return sig * (1 - sig)
    }
    
    func updateGrad(truth : Double, nextLayer : Layer?, idx : Int) {
        if let nl = nextLayer{
            let weights = nl.neurons.map { n in
                n.inputWeights[idx]
            }
            let grads = nl.neurons.map { n in
                n.grad
            }
            let sum = dotProduct(x: weights, y: grads)
            grad = dSigmoid(x:a) * sum
        } else {
            grad = dSigmoid(x:a) * (truth - s)
        }
    }
    
    func updateWeight(prevLayer : Layer?){
        for i in (0..<inputWeights.count){
            let temp = (learningRate * (prevLayer?.neurons[i].s)! * grad)
            inputWeights[i] = inputWeights[i] + temp
        }
    }
}
