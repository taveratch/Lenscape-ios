//
//  FilterViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 30/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController {

    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var partOfDayLabel: UILabel!
    @IBOutlet weak var seasonButton: UITableViewCell!
    @IBOutlet weak var partOfDayButton: UITableViewCell!
    
    var seasons: [Season] = []
    var partsOfDay: [PartOfDay] = []
    var delegate: FilterViewControllerDelegate?
    
    var season: Season?
    var partOfDay: PartOfDay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPartsOfDay()
        fetchSeasons()
        setupGestures()
        // Do any additional setup after loading the view.
    }
    
    private func fetchPartsOfDay() {
        Api.getPartsOfDay().done {
            partsOfDay in
            self.partsOfDay = partsOfDay
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? "Error"
                self.showAlertDialog(title: "Error", message: message)
        }
    }
    
    private func fetchSeasons() {
        Api.getSeasons().done {
            seasons in
            self.seasons = seasons
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? "Error"
                self.showAlertDialog(title: "Error", message: message)
        }
    }
    
    private func setupGestures() {
        addTapGesture(for: seasonButton, with: #selector(showSeasonList))
        addTapGesture(for: partOfDayButton, with: #selector(showPartOfDayList))
    }
    
    @objc private func showSeasonList() {
        let texts = seasons.map { $0.name }
        showListTableViewController(texts: texts, items: seasons, title: "Seasons")
    }
    
    @objc private func showPartOfDayList() {
        let texts = partsOfDay.map { $0.name }
        showListTableViewController(texts: texts, items: partsOfDay, title: "Parts of Day")
    }
    
    private func showListTableViewController(texts: [String], items: [Any], title: String="") {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.ListTableViewController.rawValue) as! ListTableViewController
        vc.texts = texts
        vc.items = items
        vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        vc.title = title
        present(navigationController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func createFilter(_ sender: UIBarButtonItem) {
        if let delegate = delegate {
            delegate.didFilterCreate(season: self.season, partOfDay: self.partOfDay)
        }
        dismiss(animated: true)
    }
    
}

extension FilterViewController: ListTableViewControllerDelegate {
    func didSelectItem(item: Any, index: Int) {
        switch item {
        case is Season:
            self.season = item as! Season
            self.seasonLabel.text = self.season!.name
        case is PartOfDay:
            self.partOfDay = item as! PartOfDay
            self.partOfDayLabel.text = self.partOfDay!.name
        default:
            break
        }
    }
}
