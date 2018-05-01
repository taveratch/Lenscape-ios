//
//  FilterViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 30/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import SwiftCarousel

class FilterViewController: UIViewController {

    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var partOfDayLabel: UILabel!
    @IBOutlet weak var seasonButton: UITableViewCell!
    @IBOutlet weak var partOfDayButton: UITableViewCell!
    @IBOutlet weak var seasonScrollView: CircularInfiniteScroll!
    @IBOutlet weak var partOfDayScrollView: CircularInfiniteScroll!
    @IBOutlet weak var partOfDaySwitch: UISwitch!
    @IBOutlet weak var seasonSwitch: UISwitch!
    
    var seasons: [Season] = []
    let seasonColors = [#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.8431372549, blue: 0.6823529412, alpha: 1),#colorLiteral(red: 0.6439188241, green: 0.8235294118, blue: 0.8196078431, alpha: 1),#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1)]
    let partOfDayColors = [#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1), #colorLiteral(red: 0.7725490196, green: 0.6392156863, blue: 0.4666666667, alpha: 1), #colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.6549019608, blue: 0.2666666667, alpha: 1), #colorLiteral(red: 1, green: 0.7803921569, blue: 0.5450980392, alpha: 1), #colorLiteral(red: 1, green: 0.8431372549, blue: 0.6823529412, alpha: 1), #colorLiteral(red: 0.7607843137, green: 0.8274509804, blue: 0.8156862745, alpha: 1), #colorLiteral(red: 0.6439188241, green: 0.8235294118, blue: 0.8196078431, alpha: 1),#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1)]
    var partsOfDay: [PartOfDay] = []
    var delegate: FilterViewControllerDelegate?
    
    var season: Season?
    var partOfDay: PartOfDay?
    
    let SEASON_TAG = 0
    let POD_TAG = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        overlayBlurredBackgroundView()
        setupSeasonScrollView()
        setupPartOfDayScrollView()
        // Do any additional setup after loading the view.
    }
    
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        blurredBackgroundView.alpha = 0
        view.addSubview(blurredBackgroundView)
        view.sendSubview(toBack: blurredBackgroundView)
        UIView.animate(withDuration: 2, animations: {
            blurredBackgroundView.alpha = 1
        })
    }
    
    private func setupUI() {
        setupSeasonScrollView()
    }
    
    func createSeasonLabelForScrollView(index: Int) -> CircularScrollViewItem {
        let string = self.seasons[index].name
        let viewContainer = CircularScrollViewItem()
        viewContainer.label.text = string
        viewContainer.label.font = .systemFont(ofSize: 14.0)
        viewContainer.contentView.startColor = seasonColors[index]
        viewContainer.contentView.endColor = seasonColors[index+1]
        viewContainer.contentView.sizeToFit()
        viewContainer.tag = SEASON_TAG
        return viewContainer
    }
    
    func createPartOfDayLabelForScrollView(index: Int) -> CircularScrollViewItem {
        let string = self.partsOfDay[index].name
        let viewContainer = CircularScrollViewItem()
        viewContainer.label.text = string
        viewContainer.label.font = .systemFont(ofSize: 14.0)
        viewContainer.contentView.startColor = partOfDayColors[index]
        viewContainer.contentView.endColor = partOfDayColors[index+1]
        viewContainer.contentView.sizeToFit()
        viewContainer.tag = POD_TAG
        return viewContainer
    }
    
    private func setupSeasonScrollView() {
        // MARK: Seasoning Scroll View
        do {
            try seasonScrollView.carousel.itemsFactory(itemsCount: self.seasons.count, factory: createSeasonLabelForScrollView)
        } catch  {
        }
        var currentIndex: Int? = nil
        if season != nil {
            currentIndex = seasons.index(where: { (item) -> Bool in
                item.id == self.season!.id
            })
        }
        seasonScrollView.carousel.delegate = self
        seasonScrollView.carousel.resizeType = .visibleItemsPerPage(3)
        seasonScrollView.carousel.defaultSelectedIndex = currentIndex == nil ? self.seasons.count / 2 : currentIndex!
    }
    
    private func setupPartOfDayScrollView() {
        // MARK: Seasoning Scroll View
        do {
            try partOfDayScrollView.carousel.itemsFactory(itemsCount: self.partsOfDay.count, factory: createPartOfDayLabelForScrollView)
        } catch  {
        }
        var currentIndex: Int? = nil
        if partOfDay != nil {
            currentIndex = partsOfDay.index(where: { (item) -> Bool in
                item.id == self.partOfDay!.id
            })
        }
        partOfDayScrollView.carousel.delegate = self
        partOfDayScrollView.carousel.resizeType = .visibleItemsPerPage(3)
        partOfDayScrollView.carousel.defaultSelectedIndex = currentIndex == nil ? self.partsOfDay.count / 2 : currentIndex!
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
            self.setupSeasonScrollView()
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? "Error"
                self.showAlertDialog(title: "Error", message: message)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func createFilter(_ sender: UIButton) {
        if !seasonSwitch.isOn {
            self.season = nil
        }
        if !partOfDaySwitch.isOn {
            self.partOfDay = nil
        }
        if let delegate = delegate {
            delegate.didFilterCreate(season: self.season, partOfDay: self.partOfDay)
        }
        dismiss(animated: true)
    }
    
}

extension FilterViewController: SwiftCarouselDelegate {
    func didSelectItem(item: UIView, index: Int, tapped: Bool) -> UIView? {
        switch item.tag {
        case SEASON_TAG:
            if seasonSwitch.isOn {
                let season = seasons[index]
                self.season = season
            }
        case POD_TAG:
            if partOfDaySwitch.isOn {
                let partOfDay = partsOfDay[index]
                self.partOfDay = partOfDay
            }
        default:
            break
        }
        return item
    }
}
