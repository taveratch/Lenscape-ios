//
//  PlaceRecentPhotoViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 23/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class PlaceRecentPhotoViewController: UIViewController {

    var images: [Image] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(images.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension PlaceRecentPhotoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.images.count
    }
}
