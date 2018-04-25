//
//  PhotoPostViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 12/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Alamofire
import GooglePlaces

class PhotoPostViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: ShadowView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var informationCard: PhotoUploadInformationCard!
    
    var image: UIImage?
    let photoUploader = PhotoUploader()
    var place: Place?
    var season: Season?
    var dateTaken: Date = Date()
    var partOfDay: PartOfDay?
    var seasons: [Season] = []
    var partsOfDay: [PartOfDay] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSeasons()
        fetchPartsOfDay()
        setupUI()
        setupKeyboard()
        
        setupGestures()
        
        //https://github.com/lkzhao/Hero/issues/187
        informationCard.hero.modifiers = [.duration(0.4), .translate(y: informationCard.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
        // Shared hero's id with PhotoPreviewViewController
//        shareButton.hero.id = "Next"
        
        runThisAfter(second: 0.1) {
            self.informationCard.caption.becomeFirstResponder()
        }
    }
    
    // MARK: Setup for moving view to show textfield when keyboard is presented
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if place != nil { // do not show keyboard if come from GooglePlacesAutoCompleteViewController
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }

    private func runThisAfter(second: Double, execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (second), execute: execute)
    }
    
    // https://stackoverflow.com/questions/5143873/dismissing-the-keyboard-in-a-uiscrollview?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    private func setupKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        informationCard.caption.resignFirstResponder()
    }
    
    private func setupUI() {
        imageView.image = image
        informationCard.caption.delegate = self
        informationCard.dateTakenPicker.isHidden = true
        
        let time = Double(dateTaken.timeIntervalSince1970 * 1000)
        let (dateString, _) = DateUtil.getDateTimeString(of: time)
        informationCard.dateTakenLabel.text = dateString
        informationCard.dateTakenLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func fetchSeasons() {
        Api.getSeasons().done {
            seasons in
            self.seasons = seasons
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? ""
                AlertController.showAlert(viewController: self, message: message)
        }
    }
    
    private func fetchPartsOfDay() {
        Api.getPartsOfDay().done {
            partsOfDay in
            self.partsOfDay = partsOfDay
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? ""
                AlertController.showAlert(viewController: self, message: message)
        }
    }
    
    @objc func back() {
        let alert = UIAlertController(title: "Cancel", message: "Cancel sharing photo?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: SegueIdentifier.UnwindToCameraAndDismiss.rawValue, sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func closeMe() {
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    * Are all required information filled or not.
        1. Caption
        2. Place
    */
    private func isValid() -> Bool {
        return !informationCard.caption.text!.isEmpty
            && place != nil
            && season != nil
            && partOfDay != nil
            && dateTaken != nil
    }
    
    @objc func upload() {
        if !isValid() {
            AlertController.showAlert(viewController: self, message: "Please fill in the information.")
            return
        }
        if let data = UIImageJPEGRepresentation(image!,1) {
            
            let encodedPlace = try? JSONEncoder().encode(place)
            let imageInfo: [String: Any] = [
                "picture": data,
                "image_name": informationCard.caption.text!,
                "place": encodedPlace,
                "season": season!.id,
                "time": partOfDay!.id,
                "date_taken": Int(dateTaken.timeIntervalSince1970 * 1000)
            ]

            // the data can be passed to ExploreViewController via UserDefaults
            UserDefaults.standard.set(imageInfo, forKey: "uploadPhotoInfo")
            self.performSegue(withIdentifier: SegueIdentifier.UnwindToCameraAndDismiss.rawValue, sender: self)
        }
    }
    
    private func setupGestures() {
        informationCard.shareButton.addTarget(self, action: #selector(upload), for: .touchUpInside)
        ComponentUtil.addTapGesture(parentViewController: self, for: backButton, with: #selector(back))
        ComponentUtil.addTapGesture(parentViewController: self, for: informationCard.placeLabel, with: #selector(showSearchPlaceViewController))
        ComponentUtil.addTapGesture(parentViewController: self, for: informationCard.seasonView, with: #selector(showSeasonsList))
        ComponentUtil.addTapGesture(parentViewController: self, for: informationCard.timeTakenView, with: #selector(showPartsOfDayList))
        ComponentUtil.addTapGesture(parentViewController: self, for: informationCard.dateTakenView, with: #selector(toggleDateTakenPicker))
        informationCard.dateTakenPicker.addTarget(self, action: #selector(handleDateTakenValueChanged), for: .valueChanged)
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
    
    @objc private func showSeasonsList() {
        let texts = seasons.map { $0.name }
        showListTableViewController(texts: texts, items: seasons, title: "Seasons")
    }
    
    @objc private func showPartsOfDayList() {
        let texts = partsOfDay.map { $0.name }
        showListTableViewController(texts: texts, items: partsOfDay, title: "Parts of day")
    }
    
    @objc private func toggleDateTakenPicker() {
        UIView.animate(withDuration: 0.3, animations: {
            self.informationCard.dateTakenPicker.isHidden = !self.informationCard.dateTakenPicker.isHidden
        })
    }
    
    @objc private func handleDateTakenValueChanged(sender: UIDatePicker) {
        dateTaken = sender.date
        let time = Double(sender.date.timeIntervalSince1970 * 1000)
        let (dateString, _) = DateUtil.getDateTimeString(of: time)
        informationCard.dateTakenLabel.text = dateString
        informationCard.dateTakenLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
    }
    
    @objc private func showSearchPlaceViewController() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.GooglePlacesAutoCompleteViewController.rawValue) as! GooglePlacesAutoCompleteViewController
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 50, 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            var aRect: CGRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            
            if !aRect.contains(informationCard.caption.frame.origin) {
                self.scrollView.scrollRectToVisible(informationCard.caption.frame, animated: true)
            }
        }
    }
    
}

extension PhotoPostViewController: GooglePlacesAutoCompleteViewControllerDelegate {
    func didSelectPlace(place: Place) {
        self.informationCard.placeLabel.text = place.name
        self.informationCard.placeLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.place = place
    }
}

extension PhotoPostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

extension PhotoPostViewController: ListTableViewControllerDelegate {
    func didSelectItem(item: Any, index: Int) {
        switch item {
        case is Season:
            let season = item as! Season
            self.season = season
            self.informationCard.seasonLabel.text = season.name
            self.informationCard.seasonLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        case is PartOfDay:
            let partOfDay = item as! PartOfDay
            self.partOfDay = partOfDay
            self.informationCard.partOfDayLabel.text = partOfDay.name
            self.informationCard.partOfDayLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        default:
            break
        }
    }
}
