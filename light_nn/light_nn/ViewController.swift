//
//  ViewController.swift
//  light_nn
//
//  Created by aaron on 2021/6/26.
//

import UIKit
class ViewController: UIViewController {

    var imageView : UIImageView = UIImageView(frame: CGRect(x: 100, y: 200, width: 100, height: 100))
    var btn : UIButton = UIButton(frame: CGRect(x: 100, y: 50, width: 100, height: 50))
    var btnSave : UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    var btnLoad : UIButton = UIButton(frame: CGRect(x: 200, y: 100, width: 100, height: 50))
    var btn1 : UIButton = UIButton(frame: CGRect(x: 100, y: 150, width: 100, height: 50))
    var btnTest : UIButton = UIButton(frame: CGRect(x: 200, y: 150, width: 100, height: 50))
    var btnE : UIButton = UIButton(frame: CGRect(x: 50, y: 670, width: 100, height: 50))
    var btnTestSwitch : UIButton = UIButton(frame: CGRect(x: 100, y: 350, width: 150, height: 50))
    var net = NerualNet(shape: [784, 28, 10])
    var resultLb = UILabel(frame: CGRect(x: 100, y: 420, width: 100, height: 50))
    var dataSet = MNISTDataSet()
    var testIdx = 17
    
    override func viewDidLoad() {
        super.viewDidLoad()
    // Do any additional setup after loading the view.
    
//        print(net.getOutputs(input: [1.2, 1,1]))

        dataSet.load()
        
        view.addSubview(imageView)
        view.addSubview(btn)
        view.addSubview(btn1)
//        view.addSubview(btnE)
        view.addSubview(btnSave)
        view.addSubview(btnLoad)
        view.addSubview(btnTestSwitch)
        view.addSubview(btnTest)
        view.addSubview(resultLb)
        imageView.image = convertImage(data: dataSet.trainImages[testIdx])
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        _ = [btn,btn1,btnSave,btnLoad,btnTest,btnTestSwitch].map{
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.black.cgColor
            var frame = $0.frame
            frame.size.height = 30
            $0.frame = frame
        }
        
        btn.setTitle("Start Train", for: UIControl.State.normal)
        btn.addAction(UIAction(handler: { action in
            self.train()
        }), for: .touchUpInside)
        
        
        btn1.setTitle("Pred", for: UIControl.State.normal)
        btn1.addAction(UIAction(handler: { action in
            self.test()
        }), for: .touchUpInside)
                
        btnSave.setTitle("Save", for: UIControl.State.normal)
        btnSave.addAction(UIAction(handler: { action in
            self.save()
        }), for: .touchUpInside)
        
        btnLoad.setTitle("Load", for: UIControl.State.normal)
        btnLoad.addAction(UIAction(handler: { action in
            self.load()
        }), for: .touchUpInside)
        
        btnTest.setTitle("Test", for: UIControl.State.normal)
        btnTest.addAction(UIAction(handler: { action in
            self.testAll(step: 0)
        }), for: .touchUpInside)
        
        btnTestSwitch.setTitle("Switch Test Img", for: UIControl.State.normal)
        btnTestSwitch.addAction(UIAction(handler: { action in
            self.testIdx = self.testIdx + 1
            self.imageView.image = convertImage(data: self.dataSet.testImages[self.testIdx])
        }), for: .touchUpInside)
        
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn1.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btnE.setTitleColor(.black, for: UIControl.State.normal)
        btnSave.setTitleColor(.black, for: UIControl.State.normal)
        btnLoad.setTitleColor(.black, for: UIControl.State.normal)
        btnTestSwitch.setTitleColor(.black, for: UIControl.State.normal)
        btnTest.setTitleColor(.black, for: UIControl.State.normal)
        resultLb.textColor = .black
        resultLb.font = UIFont.systemFont(ofSize: 24)
        self.net.testBlock = { a in
            DispatchQueue.main.sync {
                self.testAll(step: a)
            }
        }
    }
    
    func train()  {
        DispatchQueue.global().async { [unowned self] in
            print("training begin")
            for i in (0..<3){
                self.net.train(inputs: self.dataSet.regularizationImage(), labels: self.dataSet.regularizationLabel())
                NSLog("batch %d end", i)
            }
            print("training end")
        }
    }
    
    func save(){
        let currentModel = net.export()
        
        UserDefaults.standard.setValue(currentModel, forKey: "model_weights")
        
    }
    
    func testAll(step : Int){
        var correct = 0
        for i in (1..<self.dataSet.testImages.count){
            let item = self.dataSet.testImages[i]
            let imageData = item.map{Double($0) / 255}
            let output = net.getOutputs(input: imageData)
            let r = Int(output.firstIndex(of: output.max()!)!)
            let truthR = Int(self.dataSet.testLabels[i])
            if r == truthR{
                correct = correct + 1
            }
        }
        if step > 0{
            resultLb.text = "step \(step) accuracy: \(Double(correct) / Double(self.dataSet.testLabels.count))"
        }else{
            resultLb.text = "model accuracy: \(Double(correct) / Double(self.dataSet.testLabels.count))"

        }
        resultLb.sizeToFit()
        NSLog("accuracy at step %d: %f", step,Double(correct) / Double(self.dataSet.testLabels.count))
    }
    
    func load(){
        
        let model = UserDefaults.standard.array(forKey: "model_weights")
        if let unwrapModel = model{
            let currentModel = unwrapModel as! [[[Double]]]
            for i in (0..<net.layers.count){
                let l = net.layers[i]
                for j in (0..<l.neurons.count){
                    let n = l.neurons[j]
                    for k in (0..<n.inputWeights.count){
                        n.inputWeights[k] = currentModel[i][j][k]
                    }
                }
            }
            resultLb.text = "loaded model"
        }else{
            resultLb.text = "no model found in userdefault"
        }
        resultLb.sizeToFit()

        NSLog("load weights")
        
    }
    
    func test(){
        let imageData = self.dataSet.testImages[testIdx].map{Double($0)}
        let output = self.net.getOutputs(input: imageData)
        print(output)
        let r = output.firstIndex(of: output.max()!)!
        print("final result is", r)
        resultLb.text = "Result: \(r)"
        resultLb.sizeToFit()
    }

}

