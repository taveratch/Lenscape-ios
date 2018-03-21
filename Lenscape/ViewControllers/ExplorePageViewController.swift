//
//  ExplorePageViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 21/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class ExplorePageViewController: UIPageViewController {
    
    internal lazy var views:[UIViewController] = {
        return [newViewController(storyboardID: Identifier.ExploreViewController.rawValue),
                newViewController(storyboardID: Identifier.ExploreMapViewController.rawValue)]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let firstView = views.first {
            setViewControllers([firstView], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func newViewController(storyboardID: String) -> UIViewController {
        return self.storyboard!.instantiateViewController(withIdentifier: storyboardID)
    }

}

extension ExplorePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = views.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard views.count > previousIndex else {
            return nil
        }
        return views[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = views.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard views.count != nextIndex else {
            return nil
        }
        
        guard views.count > nextIndex else {
            return nil
        }
        return views[nextIndex]
    }
}
