//
//  ViewController.swift
//  ParaClientExample
//
//  Created by Alex on 19.04.16 г..
//  Copyright © 2016 г. Erudika. All rights reserved.
//

import UIKit
import ParaClient

class ViewController: UIViewController {

	var pc:ParaClient {
		let p = ParaClient(accessKey: "app:para", secretKey: "0gtTwKGbueiwRVOCj+z7L4KbAUx7RQiPxu+DLcQaTGnpg1bEuHRzQw==")
		//p.setEndpoint("http://localhost:8080")
		p.setEndpoint("http://192.168.0.114:8080")
		return p
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBOutlet weak var texts: UILabel!
	
	@IBAction func buttonTapped(sender: AnyObject) {
		pc.getTimestamp({ response in
			self.texts.text = String(response)
		})
	}
	
	

}

