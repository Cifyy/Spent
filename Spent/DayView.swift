//
//  DayView.swift
//  spent1
//
//  Created by Jakub Majka on 12/11/24.
//

import SwiftUI
import Charts


struct DayView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var day: DayHistory
    @State private var iconWidth: Double = 0
    
    @State var selectedCategory: Double? = nil
    @State var pickerSelectedCategory: String
    @State var selectedRange: (category: spentCategory, amount: Double)?
    @State var userAltered = false
    @State var selectedItem: SpentItem?
    
    var totalValue: Double = 0.0
    var data: [(category: spentCategory, amount: Double)]
    var cumulativeSpentRangesForStyles: [(category: spentCategory, range: Range<Double>)]
    
    func categoriesMatch(category: spentCategory) -> Bool{
        if pickerSelectedCategory == "All" { return true }
        if selectedRange == nil { return false}
        return selectedRange!.category == category
    }
    
    init(day: DayHistory) {
        self.day = day
        
        self.data = {
            var chartData: [(category: spentCategory, amount: Double)] = []
            for category in spentCategory.allCases{
                let item = (category: category, amount: day.spentItems.reduce(0){ $0 + ($1.category == category ? $1.amount : 0 )})
                if item.amount == 0 { continue }
                chartData.append(item)
            }
            return chartData
        }()
        
        var cumulative = 0.0
        self.cumulativeSpentRangesForStyles = data.map { item in
            let newCumulative = cumulative + Double(item.amount)
            let result = (category: item.category, range: cumulative ..< newCumulative)
            cumulative = newCumulative
            return result
        }
        
        var max = 0
        for (index,item) in data.enumerated() {
            totalValue += item.amount
            if item.amount > data[max].amount{
                max = index
            }
        }
        self.selectedRange = data[max]
        self.pickerSelectedCategory = data[max].category.rawValue
        
    }
    
    
    var body: some View {
        
        NavigationStack {
            List{
                Chart(data, id: \.category) { item in
                    SectorMark(
                        angle: .value("Spent", item.amount),
                        innerRadius: .ratio(0.618),
                        outerRadius: categoriesMatch(category: item.category) ? .ratio(1) : .ratio(0.9),
                        angularInset: 1.5
                    )
                    .cornerRadius(5.0)
                    .foregroundStyle(by: .value("Name", item.category.rawValue))
                    .opacity(categoriesMatch(category: item.category) || pickerSelectedCategory == "All" ? 1 : 0.4)
                }
                .padding(.top, 10)
                .chartLegend(alignment: .center, spacing: 18)
                .chartAngleSelection(value: $selectedCategory)
                .scaledToFit()
                .listRowBackground(Color.clear)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        let frame = geometry[chartProxy.plotFrame!]
                        VStack {
                            if(!userAltered){
                                Text("Spent the most on")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            Text(selectedRange?.category.rawValue.capitalized ?? "Total")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Text((selectedRange?.amount ?? totalValue).toCurrency)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                }
                .onChange(of: selectedCategory){ oldValue, newValue in
                    if let newValue{
                        withAnimation{
                            userAltered = true
                            getSelectedCategory(value: newValue)
                        }
                    }
                    
                }
                
                Section(
                    header:
                        HStack{
                            Text("Transactions").foregroundStyle(.primary)
                            Spacer()
                            //                            Menu{
                            Picker("Category", selection: $pickerSelectedCategory){
                                Text("All").tag("All")
                                ForEach(data, id: \.category){ item in
                                    Text(item.category.rawValue).tag(item.category.rawValue)
                                    
                                }
                            }
                            .onReceive([self.pickerSelectedCategory].publisher.first()) { category in
                                if category != selectedRange?.category.rawValue ?? "" { userAltered = true}
                                self.objectFromCategory(category: category)
                            }
                            .pickerStyle(DefaultPickerStyle())
                        }
                ){
                    ForEach(day.spentItems.filter {categoriesMatch(category: $0.category)}) { item in
                        
                        Button{
                            selectedItem = item
                        }label:{
                            HStack {
                                if pickerSelectedCategory == "All" {
                                    categorySymbols.image(name: item.category.rawValue)
                                        .sync(with: $iconWidth)
                                        .frame(width: iconWidth)
                                }
                                categorySymbols.image(name: item.category.rawValue)
                                    .sync(with: $iconWidth)
                                    .frame(width: iconWidth)
                                Text(item.friendlyName).lineLimit(1)
                                Spacer()
                                
                                Text(item.amount.toCurrency)
                                Image(systemName: "chevron.right")
                                    .fontDesign(.rounded)
                                    .foregroundStyle(Color.gray).opacity(0.8).offset(x: 8)
                        
                            }
                            .onPreferenceChange(SymbolWidthPreferenceKey.self) { iconWidth = $0 }
                            .foregroundStyle(Color.white)
                            .padding(5)
                            .onPreferenceChange(SymbolWidthPreferenceKey.self) { iconWidth = $0 }
                        }
                        
                    }
                    
                    .onDelete{ indexSet in
                        
                        for i in indexSet {
                            let spentItem = day.spentItems.filter{categoriesMatch(category: $0.category)} [i]
                            modelContext.delete(spentItem)
                        }
                        
                        try? modelContext.save()
                        
                        if day.spentItems.isEmpty {
                            modelContext.delete(day)
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }else {
                            if day.spentItems.filter({categoriesMatch(category: $0.category)}).count == 0{
                                pickerSelectedCategory = "All"
                                selectedRange = nil
                                
                            }
                        }
                    }
                    
                }
            }
            .listSectionSpacing(0)
            .sheet(item: $selectedItem){ item in
                SpentItemView(spentItem: item )
                    .presentationDetents([.medium])
            }
        }.navigationTitle(day.date.formatted(date: .complete, time: .omitted))
    }
    func objectFromCategory(category: String) {
        if category == "All" {
            selectedRange = nil
            return
        }
        for (index,item) in cumulativeSpentRangesForStyles.enumerated() {
            if(item.category.rawValue == category){
                withAnimation{ selectedRange = data[index] }
                return
            }
        }
    }
    
    private func getSelectedCategory(value: Double?){
        if value == nil { return }
        if let selectedCategory,
           let selectedIndex = cumulativeSpentRangesForStyles
            .firstIndex(where: { $0.range.contains(value!) }) {
            selectedRange = data[selectedIndex]
            pickerSelectedCategory = selectedRange?.category.rawValue ?? "All"
        }
    }
    
}

//#Preview {
//    DayView()
//}
