//
//  PreferencesData.swift
//  TFG
//
//  Created by Johannes Berger on 04.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import RealmSwift

class Preference: Object{
    dynamic var immediateFeedback = false
    dynamic var lockSeconds = 2
}

class MyColor: Object {
    dynamic var red = 0
    dynamic var green = 0
    dynamic var blue = 0
    let isAssignedTo = LinkingObjects(fromType: Topic.self, property: "color")
}