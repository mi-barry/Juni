//
//  PersonEntity+CoreDataProperties.swift
//  fard
//
//  Created by Michael Barry on 6/5/21.
//
//

import Foundation
import CoreData


extension PersonEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonEntity> {
        return NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
    }

    @NSManaged public var activityLevel: Double
    @NSManaged public var age: Int32
    @NSManaged public var basalTDEE: Int32
    @NSManaged public var dailyIntake: Int32
    @NSManaged public var adjustedTDEE: Int32
    @NSManaged public var gender: String?
    @NSManaged public var height: Int32
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var totalCaloriesBurned: Int32
    @NSManaged public var totalCaloriesConsumed: Int32
    @NSManaged public var totalWeightLost: Float
    @NSManaged public var weight: Int32

}

extension PersonEntity : Identifiable {

}
