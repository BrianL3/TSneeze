//
//  ChartViewController.swift
//  TSneeze
//
//  Created by Brian Ledbetter on 6/15/16.
//  Copyright © 2016 Brian Ledbetter. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class ChartViewController: UIViewController, WKScriptMessageHandler {
    
    private var webView : WKWebView?
    
    var digester = DataDigester()
    var scatterPlotData : [[Double]]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Configuration: add all functions in the JS file that need a native endpoint.
        let config = WKWebViewConfiguration()
//        config.userContentController.addUserScript(userScript)
        config.userContentController.add(self, name: "callbackHandler")
        
        // create the webview
        self.webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        self.view.addSubview(self.webView!)
        webView!.translatesAutoresizingMaskIntoConstraints = false;
        webView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.view.backgroundColor = .yellow

    }
    override func viewDidAppear(_ animated: Bool) {
        // set up the web view
        guard let bundlePath = Bundle.main.path(forResource: "index", ofType: "html") else { print("failed to create bundle path"); return; }
        print("Got bundle path: \(bundlePath)")
        guard let url = NSURL(string: bundlePath) else { print("failed to create URL with bundle of \(bundlePath)"); return; }
        print("Got URL: \(String(describing: url.absoluteString))")

        guard let data = NSData(contentsOfFile: bundlePath) else { print("Failed to create data."); return; }
        self.webView!.load(data as Data, mimeType: "text/html", characterEncodingName: "UTF-8", baseURL: url as! URL)
        
        let input = [[1, 5], [9, 8]]
        let userScript = WKUserScript(
            source: "drawUpdate('\(input)');",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        
        self.webView!.configuration.userContentController.addUserScript(userScript)

//        let context = self.webView!.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
//        context?.evaluateScript("drawUpdate")
//            self.js = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];

//        evaluateJavaScriptForData(["data" : 1])
//
//        self.webView!.evaluateJavaScript("document.getElementById('drawUpdate()').innerText") { (response, error) in
//            print("Attempted to evaluate JS")
//            print("Response was: \(response)")
//            print("Error was \(error)")
//        }
//
            CSVScanner.decodeImageMatricesFromFile("pendigits_images_reduced") { (returnedDataPoints) in
                    
            let imageTSNE = TSNE(learningRate: 30, perplexity: 50, dimensionality: 2, X: returnedDataPoints)
        
            print("Attempting to get solution")
            for x in 0 ..< 1000 {
                if (x % 300 == 0) { print("working... step \(x)") }
                imageTSNE.iterateSolution({ (plotData) in
                    // do stuff with the data call webView.evaluateJavascript
                })
            }
            print("complete")
        }
    
    }
    
    //update data
    func evaluateJavaScriptForData(dictionaryData: [String : NSNumber]) {
        
        
//        webView!.evaluateJavaScript("document.getElementById('anonymousFormSubmit').click();", nil)
        
        // Convert dictionary into encoded json
        let serializedData = try! JSONSerialization.data(withJSONObject: dictionaryData, options: .prettyPrinted)
        let encodedData = serializedData.base64EncodedData(options:.endLineWithLineFeed )
        // This WKWebView API to calls 'reloadData' function defined in js
        self.webView!.evaluateJavaScript("drawUpdate('\(encodedData)');") { (object: Any?, error: Error?) -> Void in
            print("completed with \(object), error was \(error)")
            }
    }

    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let sentData = message.body as! NSDictionary
        
        print("Received Callback from JS with this info: \(sentData)")
    }

    
    // half values that are less than 1
    // half values that are more than
    func generateTestData() -> HighDimensionalSet {
        var classifications = [String]()
        var dataSet = [ImageDataPoint]()
        for _ in 0 ..< 100 {
            let vector = [Double(arc4random()) / Double(UINT32_MAX), Double(arc4random()) / Double(UINT32_MAX)]
            let littleI = ImageDataPoint(withPoints: vector, withClassification: nil)
            dataSet.append(littleI)
            classifications.append("1")
        }
        
        for _ in 0 ..< 100 {
            let vector = [Double(arc4random()) / Double(UINT32_MAX)+3, Double(arc4random()) / Double(UINT32_MAX)+3]
            let bigI = ImageDataPoint(withPoints: vector, withClassification: nil)
            dataSet.append(bigI)
            classifications.append("3")

        }
        for _ in 0 ..< 100 {
            let vector = [Double(arc4random()) / Double(UINT32_MAX)+100, Double(arc4random()) / Double(UINT32_MAX)+100]
            let bigI = ImageDataPoint(withPoints: vector, withClassification: nil)
            dataSet.append(bigI)
            classifications.append("100")
        }
        for _ in 0 ..< 100 {
            let vector = [Double(arc4random()) / Double(UINT32_MAX)+110, Double(arc4random()) / Double(UINT32_MAX)+110]
            let bigI = ImageDataPoint(withPoints: vector, withClassification: nil)
            dataSet.append(bigI)
            classifications.append("110")
        }

        var sims = [SimilarityComparable]()
        for v in dataSet {
            sims.append(v as SimilarityComparable)
        }
        let highD = HighDimensionalSet(dataSet: sims, sigmas: nil, classifications: classifications)
        return highD
    }

}
