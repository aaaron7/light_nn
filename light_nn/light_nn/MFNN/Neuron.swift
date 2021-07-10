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
    var derivative : Double = 0.0
    var b : Double = 0.0
    var learningRate : Double = 0.006
    var a : Double = 0.0
    var s : Double = 0.0
    
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
    
    func makeWeightsRandom(){
//        inputWeights = inputWeights.map{_ in 0.3 * 2 - 1}
        inputWeights = inputWeights.map{_ in drand48() * 2 - 1}
    }
    
    func sigmoid(x : Double) -> Double{
        return 1.0 / (1.0 + exp(-x))
    }
    
    func dSigmoid() ->Double{
        let sig = sigmoid(x: a)
        return sig * (1 - sig)
    }
    
    func updateDerivative(truth : Double, nextLayer : Layer?, idx : Int) {
        if let layer = nextLayer{
            let weights = layer.neurons.map { n in
                n.inputWeights[idx]
            }
            
            let derivatives = layer.neurons.map { n in
                n.derivative
            }
            
            let sum = dotProduct(x: weights, y: derivatives)
            derivative = dSigmoid() * sum
        } else {
            derivative = dSigmoid() * (truth - s)
        }
    }
    
    func updateWeight(prevLayer : Layer?){
        var test = [Double]()
        for i in (0..<inputWeights.count){
            let temp = (learningRate * (prevLayer?.neurons[i].s)! * derivative)
            test.append(temp)
            inputWeights[i] = inputWeights[i] + temp
        }
//        print(test)
    }
}


class BiasNeuron : Neuron{
    override func dSigmoid() -> Double {
        return 0.0
    }
    
    override func sigmoid(x: Double) -> Double {
        return 0.0
    }
    
    override func getOutputs(input: [Double]) -> Double {
        return 1.0
    }
}
