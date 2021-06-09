//
//  StatsViewController.swift
//  fard
//
//  Created by Michael Barry on 6/5/21.
//

import UIKit

class StatsViewController: UIViewController {

    // Outlets //
    
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var maleButttonWdith: NSLayoutConstraint!
    @IBOutlet weak var femaleButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityLevelTF: UITextField!
    
    @IBOutlet weak var activityLevelView: UIView!
    @IBOutlet weak var sedentaryButton: UIButton!
    @IBOutlet weak var lightlyButton: UIButton!
    @IBOutlet weak var moderatleyButton: UIButton!
    @IBOutlet weak var veryButton: UIButton!
    @IBOutlet weak var extremelyButton: UIButton!
    
    // Actions //
    
    @IBAction func femaleButtonTapped(_ sender: Any) {
        setFemaleButtonctive()
    }
    
    @IBAction func maleButtonTapped(_ sender: Any) {
        setMaleButtonActive()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if ageTF.text == "" || heightTF.text == "" || weightTF.text == "" || selectedGender == "unspecified" || self.activityLevelValue == 0.0 || self.activityLevelValue == 0 {
            displayAlert()
        } else if selectedGender == "male" {
            let age: Int32? = Int32(ageTF.text!)
            let height: Int32? = Int32(heightTF.text!)
            let weight: Int32? = Int32(weightTF.text!)
            
            let activiyLevel = Float(self.activityLevelValue)
            let calculatedTDEE = calcTDEEMale(age: age!, height: height!, weight: weight!, activityLevel: activiyLevel)
            
            self.basalTDEE = calculatedTDEE
            self.adjustedTDEE = calculatedTDEE
            
            self.person.height = height!
            self.person.weight = weight!
            self.person.age = age!
            self.person.lastUpdated = Date()
            
            self.isFirstLaunch = false
            self.isNotUpdatedOnce = false
            
            savePerson(person: self.person)
            dismiss(animated: true, completion: nil)
        } else {
            let age: Int32? = Int32(ageTF.text!)
            let height: Int32? = Int32(heightTF.text!)
            let weight: Int32? = Int32(weightTF.text!)
            
            let activityLevel = Float(self.activityLevelValue)
            let calculatedTDEE = calcTDEEFemale(age: age!, height: height!, weight: weight!, activityLevel: activityLevel)
            
            self.basalTDEE = calculatedTDEE
            self.adjustedTDEE = calculatedTDEE
            
            self.person.height = height!
            self.person.weight = weight!
            self.person.age = age!
            self.person.lastUpdated = Date()
            
            self.isFirstLaunch = false
            self.isNotUpdatedOnce = false
            
            savePerson(person: self.person)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func activityLevelButtonTapped(_ sender: Any) {
        self.activityLevelView.isHidden = false
        dismissAllKeyboard()
    }
    
    @IBAction func sedentaryButtonTapped(_ sender: Any) {
        self.activityLevelValue = 1.2
        changeActivityButtonsBackground(activeButton: self.sedentaryButton, button1: self.lightlyButton, button2: self.moderatleyButton, button3: self.veryButton, button4: self.extremelyButton)
        self.activityLevelTF.text = "Sedentary (little to no exercise + desk job)"
        self.person.activityLevel = self.activityLevelValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  self.activityLevelView.isHidden = true
        }
    }
    
    @IBAction func lightlyButtonTapped(_ sender: Any) {
        self.activityLevelValue = 1.375
        changeActivityButtonsBackground(activeButton: self.lightlyButton, button1: self.sedentaryButton, button2: self.moderatleyButton, button3: self.veryButton, button4: self.extremelyButton)
        self.activityLevelTF.text = "Lightly Active (light exercise 1-3 days/week)"
        self.person.activityLevel = self.activityLevelValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  self.activityLevelView.isHidden = true
        }
    }
    
    @IBAction func moderatleyButtonTapped(_ sender: Any) {
        self.activityLevelValue = 1.55
        changeActivityButtonsBackground(activeButton: self.moderatleyButton, button1: self.sedentaryButton, button2: self.lightlyButton, button3: self.veryButton, button4: self.extremelyButton)
        self.activityLevelTF.text = "Moderately Active (moderate exercise 3-5 days/week)"
        self.person.activityLevel = self.activityLevelValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  self.activityLevelView.isHidden = true
        }
    }
    
    @IBAction func veryButtonTapped(_ sender: Any) {
        self.activityLevelValue = 1.725
        changeActivityButtonsBackground(activeButton: self.veryButton, button1: self.sedentaryButton, button2: self.lightlyButton, button3: self.moderatleyButton, button4: self.extremelyButton)
        self.activityLevelTF.text = "Very Active (heavy exercise 6-7 days/week)"
        self.person.activityLevel = self.activityLevelValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  self.activityLevelView.isHidden = true
        }
    }
    
    @IBAction func extremelyButtonTapped(_ sender: Any) {
        self.activityLevelValue = 1.9
        changeActivityButtonsBackground(activeButton: self.extremelyButton, button1: self.sedentaryButton, button2: self.lightlyButton, button3: self.moderatleyButton, button4: self.veryButton)
        self.activityLevelTF.text = "Extremely Active (very heavy exercise, hard labor job, training 2x a day)"
        self.person.activityLevel = self.activityLevelValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  self.activityLevelView.isHidden = true
        }
    }
    
    // Variables //
    
    let screenWidth = UIScreen.main.bounds.width
    var isFirstLaunch: Bool!
    var isNotUpdatedOnce: Bool!
    var person: PersonEntity!
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedGender = "unspecified"
    var activityLevelValue = 0.0
    var basalTDEE: Double!
    var adjustedTDEE: Double!
    
    // MARK: Scene flow //
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Basic UI setup
        
        buttonWordWrap(title: "Sedentary (little to no exercise + desk job)" , button: sedentaryButton)
        buttonWordWrap(title: "Lightly Active (light exercise 1-3 days / week)" , button: lightlyButton)
        buttonWordWrap(title: "Moderately Active (moderate exercise 3-5 days / week)" , button: moderatleyButton)
        buttonWordWrap(title: "Very Active (heavy exercise 6-7 days / week)" , button: veryButton)
        buttonWordWrap(title: "Extremely Active (very heavy exercise, hard labor job, training 2x a day)" , button: extremelyButton)
        
        self.saveButton.layer.cornerRadius = 7
        self.ageTF.borderStyle = .none
        self.ageTF.keyboardType = .numberPad
        self.heightTF.borderStyle = .none
        self.heightTF.keyboardType = .numberPad
        self.weightTF.borderStyle = .none
        self.weightTF.keyboardType = .numberPad
        self.activityLevelTF.borderStyle = .none
        self.maleButttonWdith.constant = (screenWidth/2) - 20
        self.femaleButtonWidth.constant = (screenWidth/2) - 20
        
        self.sedentaryButton.layer.cornerRadius = 7
        self.lightlyButton.layer.cornerRadius = 7
        self.moderatleyButton.layer.cornerRadius = 7
        self.veryButton.layer.cornerRadius = 7
        self.extremelyButton.layer.cornerRadius = 7
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.activityLevelView.isHidden = true
        checkStatsUpdated()
    }
    
    // Helper functions //
    
    // Set UI based on created or not yet created person //
    
    func checkStatsUpdated() {
        if isFirstLaunch || isNotUpdatedOnce {
            setPlaceholderText(placeholder: "Age", element: ageTF)
            setPlaceholderText(placeholder: "Height (inches)", element: heightTF)
            setPlaceholderText(placeholder: "Weight (lbs)", element: weightTF)
            setPlaceholderText(placeholder: "Activity level", element: activityLevelTF)
            maleButton.backgroundColor = UIColor.darkGray
            femaleButton.backgroundColor = UIColor.darkGray
            setAllActivityLevelButtonsGrey(button0: self.sedentaryButton, button1: self.lightlyButton, button2: self.moderatleyButton, button3: self.veryButton, button4: self.extremelyButton)
        } else {
            setUIWithCurrentStats(person: person)
        }
    }
    
    // Set label placeholder text with custom color //
    
    func setPlaceholderText(placeholder: String, element: UITextField) {
        element.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    // Set UI with current stats //
    
    func setUIWithCurrentStats(person: PersonEntity) {
        if person.gender == "male" {
            setMaleButtonActive()
        } else if person.gender == "female" {
            setFemaleButtonctive()
        } else {
            selectedGender = "unspecified"
            self.maleButton.backgroundColor = UIColor.darkGray
            self.femaleButton.backgroundColor = UIColor.darkGray
        }
        self.ageTF.text = String(person.age)
        self.heightTF.text = String(person.height)
        self.weightTF.text = String(person.weight)
        self.activityLevelValue = person.activityLevel
        determineActivityLevel()
        
    }
    
    // Update male button background color //
    
    func setMaleButtonActive() {
        self.maleButton.backgroundColor = UIColor.init(red: 165/255, green: 42/255, blue: 242/255, alpha: 1.0)
        self.femaleButton.backgroundColor = UIColor.darkGray
        self.selectedGender = "male"
        self.person.gender = "male"
    }
    
    // Update female button background color when tapped //
    
    func setFemaleButtonctive() {
        self.femaleButton.backgroundColor = UIColor.init(red: 165/255, green: 42/255, blue: 242/255, alpha: 1.0)
        self.maleButton.backgroundColor = UIColor.darkGray
        self.selectedGender = "female"
        self.person.gender = "female"
    }
    
    // Display alert if age, height, or weight is empty when save tapped //
    
    func displayAlert() {
        let alert = UIAlertController(title: "Wait", message: "You must enter an age, height, weight, and gender.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Calculate TDEE male //
    
    func calcTDEEMale(age: Int32, height: Int32, weight: Int32, activityLevel: Float) -> Double {
        let weightInKg = Double(weight) * 0.453592
        let heighInCm = Double(height) * 2.54
        let calcWeight = 13.7 * weightInKg
        let calcHeight = 5 * heighInCm
        let calcAge = 6.8 * Double(age)
        let tdee = 665 + (calcWeight + calcHeight - calcAge)
        return tdee
    }
    
    // Calculate TDEE female //
    
    func calcTDEEFemale(age: Int32, height: Int32, weight: Int32, activityLevel: Float) -> Double {
        let weightInKg = Double(weight) * 0.453592
        let heighInCm = Double(height) * 2.54
        let calcWeight = 9.6 * weightInKg
        let calcHeight = 5 * heighInCm
        let calcAge = 6.8 * Double(age)
        let tdee = 665 + (calcWeight + calcHeight - calcAge)
        return tdee
    }
    
    // Save person context //
    
    func savePerson(person: PersonEntity) {
        do {
            person.basalTDEE = Int32(self.basalTDEE)
            person.adjustedTDEE = Int32(self.adjustedTDEE)
            try self.context.save()
        } catch {
            print("error saving person")
        }
    }
    
    // Dismiss any keyboard on screen //
    
    func dismissAllKeyboard() {
        self.ageTF.resignFirstResponder()
        self.heightTF.resignFirstResponder()
        self.weightTF.resignFirstResponder()
    }
    
    // Set button label to word wrap //
    
    func buttonWordWrap(title: String, button: UIButton) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
    }
    
    // Change activity level button color when one is selected //
    
    func changeActivityButtonsBackground(activeButton: UIButton, button1: UIButton, button2: UIButton, button3: UIButton, button4: UIButton) {
        activeButton.backgroundColor = UIColor.init(red: 165/255, green: 42/255, blue: 242/255, alpha: 1.0)
        button1.backgroundColor = UIColor.darkGray
        button2.backgroundColor = UIColor.darkGray
        button3.backgroundColor = UIColor.darkGray
        button4.backgroundColor = UIColor.darkGray
    }
    
    // Set all activit level buttons to unselected color //
    
    func setAllActivityLevelButtonsGrey(button0: UIButton, button1: UIButton, button2: UIButton, button3: UIButton, button4: UIButton) {
        button0.backgroundColor = UIColor.darkGray
        button1.backgroundColor = UIColor.darkGray
        button2.backgroundColor = UIColor.darkGray
        button3.backgroundColor = UIColor.darkGray
        button4.backgroundColor = UIColor.darkGray
    }
    
    // Determine activity level and set button and activity level variable //
    func determineActivityLevel() {
        if activityLevelValue == 1.2 {
            changeActivityButtonsBackground(activeButton: self.sedentaryButton, button1: self.lightlyButton, button2: self.moderatleyButton, button3: self.veryButton, button4: self.extremelyButton)
            self.activityLevelTF.text = "Sedentary (little to no exercise + desk job)"
        } else if activityLevelValue == 1.375 {
            changeActivityButtonsBackground(activeButton: self.lightlyButton, button1: self.sedentaryButton, button2: self.moderatleyButton, button3: self.veryButton, button4: self.extremelyButton)
            self.activityLevelTF.text = "Lightly Active (light exercise 1-3 days/week)"
        } else if activityLevelValue == 1.55 {
            changeActivityButtonsBackground(activeButton: self.moderatleyButton, button1: self.sedentaryButton, button2: self.lightlyButton, button3: self.veryButton, button4: self.extremelyButton)
            self.activityLevelTF.text = "Moderately Active (moderate exercise 3-5 days/week)"
        } else if activityLevelValue == 1.725 {
            changeActivityButtonsBackground(activeButton: self.veryButton, button1: self.sedentaryButton, button2: self.lightlyButton, button3: self.moderatleyButton, button4: self.extremelyButton)
            self.activityLevelTF.text = "Very Active (heavy exercise 6-7 days/week)"
        } else if activityLevelValue == 1.9 {
            changeActivityButtonsBackground(activeButton: self.extremelyButton, button1: self.sedentaryButton, button2: self.lightlyButton, button3: self.moderatleyButton, button4: self.veryButton)
            self.activityLevelTF.text = "Extremely Active (very heavy exercise, hard labor job, training 2x a day)"
        } else {
            print(activityLevelValue)
        }
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        if let parentVC = presentingViewController as? ViewController {
            DispatchQueue.main.async {
                parentVC.setUIWithCurrentStats()
                parentVC.isFirstLaunch = self.isFirstLaunch
                parentVC.isNotUpdatedOnce = self.isNotUpdatedOnce
            }
        }
    }
}
