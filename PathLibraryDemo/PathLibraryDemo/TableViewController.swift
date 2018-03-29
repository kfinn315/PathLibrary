//
//  ViewController.swift
//  PathLibraryDemo
//
//  Created by Kevin Finn on 3/27/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import PathPhoto
import PathMap
import RandomKit

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(ImagePageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil), animated: true)
            break;
        case 1:
            let path = DemoPath.random()
            let mv = MapViewController.instance
            mv.load(path: path)
            self.navigationController?.pushViewController(mv, animated: true)
            break;
        case 2:
            var paths : [DemoPath] = [DemoPath.random()]
           
            for _ in 0 ... Int.random(in: 0...20, using: &Xorshift.default)
            {
                paths.append(DemoPath.random())
            }

            let mv = AllMapViewController.instance
            mv.load(paths: paths)
            self.navigationController?.pushViewController(mv, animated: true)
            break;
        case 3:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "MapPhotos") {
                self.navigationController?.pushViewController(vc , animated: true)
            }
           
        default:
            break;
        }
    }
}

