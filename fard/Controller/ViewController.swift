//
//  ViewController.swift
//  fard
//
//  Created by Michael Barry on 6/5/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // Outlets //
    @IBOutlet weak var trackingSinceLabel: UILabel!
    @IBOutlet weak var totalCaloriesBurnedView: UIView!
    @IBOutlet weak var totalPoundsLostView: UIView!
    @IBOutlet weak var dailyIntakeView: UIView!
    @IBOutlet weak var recordCaloriesButton: UIButton!
    @IBOutlet weak var totalsNotificationLabel: UILabel!
    
    @IBOutlet weak var totalCaloriedBurnedLabel: UILabel!
    @IBOutlet weak var totalWeightLostLabel: UILabel!
    @IBOutlet weak var adjustedTDEELabel: UILabel!
    @IBOutlet weak var dailyIntakeLabel: UILabel!
    
    @IBOutlet weak var effectiveTDEEView: UIView!
    @IBOutlet weak var logCaloriesTV: UITextField!
    
    // Actions //
    @IBAction func recordButtonTapped(_ sender: Any) {
        if self.logCaloriesTV.text == "" {
            self.displayAlert(title: "Wait", message: "Enter a valid number.")
        } else if self.person.age == 0 {
            self.logCaloriesTV.resignFirstResponder()
            self.logCaloriesTV.text = ""
            self.displayAlert(title: "Wait", message: "Enter your stats before recording calories.")
        } else {
            self.logCaloriesTV.resignFirstResponder()
            logCalories()
        }
    }
    
    @IBAction func updateStatsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: MODALSTATSVIEW, sender: nil)
    }
    
    @IBAction func resetDailyTapped(_ sender: Any) {
        self.person.dailyIntake = 0
        self.dailyIntakeLabel.text = "0 cal"
        self.savePerson(person: self.person)
    }
    
    // Variables //
        
    var isFirstLaunch: Bool!
    var isNotUpdatedOnce: Bool!
    let ISLAUNCHEDONCE = "isLaunchedOnce"
    let MODALSTATSVIEW = "modalStatsView"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items:[PersonEntity]?
    var person: PersonEntity!
        
    // Scene flow //
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        // Basic UI setup //
                
        self.totalCaloriesBurnedView.layer.cornerRadius = 7
        self.totalPoundsLostView.layer.cornerRadius = 7
        self.effectiveTDEEView.layer.cornerRadius = 7
        self.dailyIntakeView.layer.cornerRadius = 7
        self.recordCaloriesButton.layer.cornerRadius = 7
        self.logCaloriesTV.borderStyle = .none
        self.logCaloriesTV.attributedPlaceholder = NSAttributedString(string: "Log calories", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.logCaloriesTV.keyboardType = .numberPad
        
        // Add dismiss keyboard on off-tap //
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector((UIView.endEditing)))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check if first launch //
        
        if !isLaunchedOnce() {
            isFirstLaunch = true
            isNotUpdatedOnce = true
            createPerson()
            fetchPerson()
            performSegue(withIdentifier: MODALSTATSVIEW, sender: nil)
        } else {
            isFirstLaunch = false
            isNotUpdatedOnce = false
            fetchPerson()
            checkPersonStats()
        }
    }
    
    // Helper functions //
    
    // Alert //
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Check if the app is being launched for the first time //
    
    func isLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: ISLAUNCHEDONCE) {
            return true
        } else {
            defaults.set(true, forKey: ISLAUNCHEDONCE)
            return false
        }
    }
    
    // Fetch person from persistent container and populate items array //
    
    func fetchPerson() {
        do {
            self.items = try context.fetch(PersonEntity.fetchRequest())
            self.person = getPersonFromItems()
        } catch {
            print("error fetching person entity")
        }
    }
    
    // Get and return frist person from items array //
    func getPersonFromItems() -> PersonEntity {
        return items![0]
    }
    
    // Create a new person and save in persistent container //
    
    func createPerson() {
        let newPerson = PersonEntity(context: self.context)
        newPerson.activityLevel = 0
        newPerson.adjustedTDEE = 0
        newPerson.age = 0
        newPerson.basalTDEE = 0
        newPerson.dailyIntake = 0
        newPerson.gender = "unspecified"
        newPerson.height = 0
        newPerson.lastUpdated = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        newPerson.startDate = Date()
        newPerson.totalCaloriesBurned = 0
        newPerson.totalCaloriesConsumed = 0
        newPerson.totalWeightLost = 0
        newPerson.weight = 0
        savePerson(person: newPerson)
    }
    
    // Check if person's stats have been set by user //
    
    func checkPersonStats() {
        if person.age == 0 {
            isNotUpdatedOnce = true
            performSegue(withIdentifier: MODALSTATSVIEW, sender: nil)
        } else {
            isNotUpdatedOnce = false
            if !isSameDay() {
                setNewStatsFromPastDay()
                setUIWithCurrentStats()
            } else {
                setUIWithCurrentStats()
            }
        }
    }
    
    // Check if user stats have been updated today //
    
    func isSameDay() -> Bool {
        let now = Date()
        let isSameDate = Calendar.current.isDate(now, inSameDayAs: self.person.lastUpdated!)
        return isSameDate
    }
    
    // Check if today is the first day of tracking //
    
    func isFirstDayTracking() -> Bool {
        let startDate = self.person.startDate
        let now = Date()
        let isStartDate = Calendar.current.isDate(startDate!, inSameDayAs: now)
        return isStartDate
    }
    
    // Save person context //
    
    func savePerson(person: PersonEntity) {
        do {
            try self.context.save()
        } catch {
            print("error saving person")
        }
    }
    
    // Calculate new stats from past day //
    
    func setNewStatsFromPastDay() {
        self.person.totalCaloriesBurned = calcTotalCaloriesBurned()
        self.person.totalWeightLost = calcTotalWeightLost()
        self.person.dailyIntake = 0
        self.person.lastUpdated = Date()
        savePerson(person: self.person)
    }
    
    // Calculate total weight lost //
    
    func calcTotalWeightLost() -> Float {
        let newTotal = Float(self.person.totalCaloriesBurned - self.person.totalCaloriesConsumed) / 3500.00
        return newTotal
    }
    
    // Calc new total calories burned from past day //
    func calcTotalCaloriesBurned() -> Int32 {
        let currentCaloriesBurned = person.totalCaloriesBurned
        let newTotal = currentCaloriesBurned + calcCaloriesBurnedLastDay(person: person)
        return newTotal
    }
    
    // Calc calories burned since last day //
    
    func calcCaloriesBurnedLastDay(person: PersonEntity) -> Int32 {
        let caloriesConsumed = person.dailyIntake
        let currentTDEE = person.basalTDEE
        let caloriesBurned = currentTDEE - caloriesConsumed
        return caloriesBurned
    }
    
    // Set UI with current person stats //
    
    func setUIWithCurrentStats() {
        self.totalCaloriedBurnedLabel.text = String(person.totalCaloriesBurned) + " cal"
        self.totalWeightLostLabel.text = String(format: "%.2f", person.totalWeightLost) + " lbs"
        self.adjustedTDEELabel.text = String(person.adjustedTDEE) + " cal"
        self.dailyIntakeLabel.text = String(person.dailyIntake) + " cal"
        self.trackingSinceLabel.text = "Tracking since: " + getDateString()
        if isFirstDayTracking() {
            self.totalsNotificationLabel.isHidden = false
        } else {
            self.totalsNotificationLabel.isHidden = true
        }
    }
    
    // Date formatter //
    
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self.person.startDate!)
    }
    
    // Log calories //
    
    func logCalories() {
        let calToAdd: Int32? = Int32(self.logCaloriesTV.text!)
        let newTotal = self.person.dailyIntake + calToAdd!
        dailyIntakeLabel.text = String(newTotal)
        person.dailyIntake = newTotal
        savePerson(person: self.person)
        self.logCaloriesTV.text = ""
    }
    
    // MARK: Navigation //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MODALSTATSVIEW {
            let controller = segue.destination as! StatsViewController
            controller.isFirstLaunch = self.isFirstLaunch
            controller.isNotUpdatedOnce = self.isNotUpdatedOnce
            controller.person = self.person
            controller.context = self.context
        }
    }
}
