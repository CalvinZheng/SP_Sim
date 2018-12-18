//
//  main.swift
//  SP_Sim
//
//  Created by Haomin Zheng on 2018-12-17.
//  Copyright © 2018 Haomin Zheng. All rights reserved.
//

import Foundation

let kStartData = 200
let kConservativeBuy = 0.9927850755
let kAggressiveBuy = 0.9789632655
let kConservativeSell = 1.013144944
let kAggressiveSell = 1.027829884

var homeDir = FileManager.init().homeDirectoryForCurrentUser
homeDir.appendPathComponent("SP_History.csv")
let SP_Data = try String(contentsOf: homeDir, encoding: .utf8)
let lines = SP_Data.components(separatedBy: "\n")

print(lines.count, lines[kStartData])

var data1 = lines[kStartData].components(separatedBy: ",")

var hasHold = false
var currentCash = 10000.0
var currentShare = 0.0
var targetPrice = Double(data1[1])! * kAggressiveBuy
var lastTradeDay = kStartData
var forceTradeNextDay = false

for index in kStartData...(lines.count-2) {
	var data = lines[index].components(separatedBy: ",")
	if hasHold {
		if forceTradeNextDay {
			print(index, "Force Sell!")
			hasHold = false
			currentCash = currentShare * Double(data[1])!
			currentShare = 0
			targetPrice = Double(data[1])! * kAggressiveBuy
			lastTradeDay = index
			forceTradeNextDay = false
		} else if Double(data[2])! >= targetPrice {
			print(index, "Sell!")
			hasHold = false
			currentCash = currentShare * targetPrice
			currentShare = 0
			targetPrice = targetPrice * kAggressiveBuy
			lastTradeDay = index
			forceTradeNextDay = false
		} else {
			// hold!
			if index - lastTradeDay > 90 {
				// sell next day
				forceTradeNextDay = true
			} else if index - lastTradeDay == 30 {
				print(index, "Adjust!")
				targetPrice = Double(data[4])! * kConservativeSell
			}
		}
	} else {
		if forceTradeNextDay {
			print(index, "Force Buy!", Double(data[1])!)
			hasHold = true
			currentShare = currentCash / Double(data[1])!
			currentCash = 0
			targetPrice = Double(data[1])! * kAggressiveSell
			lastTradeDay = index
			forceTradeNextDay = false
		} else if Double(data[3])! <= targetPrice {
			print(index, "Buy!")
			hasHold = true
			currentShare = currentCash / targetPrice
			currentCash = 0
			targetPrice = targetPrice * kAggressiveSell
			lastTradeDay = index
			forceTradeNextDay = false
		} else {
			// wait!
			if index - lastTradeDay > 90 {
				// sell next day
				forceTradeNextDay = true
			} else if index - lastTradeDay == 30 {
				print(index, "Adjust!")
				targetPrice = Double(data[4])! * kConservativeBuy
			}
		}
	}
}

print(currentCash, currentShare * Double(lines[lines.count-2].components(separatedBy: ",")[4])!)
