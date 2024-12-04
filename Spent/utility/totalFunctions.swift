//
//  totalFunctions.swift
//  spent1
//
//  Created by Jakub Majka on 4/12/24.
//
import SwiftUI
import SwiftData

func getMonthTotal(using context: ModelContext, currentMonth: Int) throws -> Double{
    let fetchDescriptor = FetchDescriptor<DayHistory>()
    let dayHistory = try context.fetch(fetchDescriptor)
    
    let currentMonthHistory = dayHistory.filter({ Int($0.date.formatted(.dateTime .month(.defaultDigits))) == currentMonth })
    return currentMonthHistory.reduce(0){$0 + $1.totalSpent}
}
func getCurrentMonthNumber() -> Int{
    return Int(Calendar.current.startOfDay(for: Date.now).formatted(.dateTime .month(.defaultDigits)))!
}
func getPreviousMonth(month: Int) -> Int{
    if month == 1 { return 12}
    return month - 1
}

enum total: Error{
    case noPreviousMonthTotal
}
func changePercentages(currentTotal: Double, previousTotal: Double) throws -> Int{
    guard previousTotal != 0 else { throw total.noPreviousMonthTotal}
    return Int(abs((currentTotal/previousTotal)*100 - 1))
}
func getChangeIcon(currentTotal: Double, previousTotal: Double) -> Text{
    if previousTotal == 0 { return Text("") }
    
    if currentTotal > previousTotal {
        return Text(Image(systemName: "arrow.up")).foregroundStyle(.red.opacity(0.8)).font(.system(size: 12))
    }
    else if currentTotal < previousTotal{
        return Text(Image(systemName: "arrow.down")).foregroundStyle(.green.opacity(0.8)).font(.system(size: 12))
    }
    return Text(Image(systemName: "-")).foregroundStyle(.gray).font(.system(size: 12))
    
}
