//
//  DayListView.swift
//  spent1
//
//  Created by Jakub Majka on 7/12/24.
//

import SwiftUI
import SwiftData

struct DayListView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @State var selectedItem: SpentItem?
    @Query(sort: \DayHistory.date, order: .reverse) var spentItemsPerDay: [DayHistory]
    
    @State private var scrollID: Int?
    @State private var iconWidth: Double = 0
    
    @Binding var position: CGFloat
    @State private var offset = CGFloat.zero
    
    
    var body: some View {
        List {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .frame(height: 0)
                .listRowBackground(Color.clear)
                .background(GeometryReader { proxy -> Color in
                                DispatchQueue.main.async {
//                                    print("----")
//                                    print(proxy.frame(in: .global).minY)
                                    position = proxy.frame(in: .global).minY
        //                            print(proxy.frame(in: .named("scroll")).maxY)
                                    
                                }
                                return Color.clear
                            })
            
            
            ForEach(spentItemsPerDay){ day in
                
                Section(header:
                            NavigationLink(){
                    DayView(day: day)
                }
                        label:{
                    HStack{
                        
                        Text(day.totalSpent.toCurrency)
                        Spacer()
                        Text(day.date.formatted(
                            .dateTime
                                .weekday(.wide)
                                .day(.defaultDigits)
                                .month(.defaultDigits)
                                .year(.defaultDigits)
                                .hour(.omitted)
                        ))
                    }.fontWeight(.medium).foregroundStyle(.gray).font(.system(size:14))
                }
                        
                ){
                    ForEach(day.spentItems){ item in
                        Button{
                            selectedItem = item
                        }label:{
                            HStack {
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
                            .foregroundStyle(Color.white)
                            .padding(5)
                            .onPreferenceChange(SymbolWidthPreferenceKey.self) { iconWidth = $0 }
                        }
                    }
                    .onDelete{ indexSet in
                        for i in indexSet {
                            let spentItem = day.spentItems[i]
                            modelContext.delete(spentItem)
                        }
                        
                        try? modelContext.save()
                        
                        if day.spentItems.isEmpty {
                            modelContext.delete(day)
                        }
                    }
                }
            }
            .sheet(item: $selectedItem){ item in
                SpentItemView(spentItem: item )
                    .presentationDetents([.medium])
            }
        }
    }
}

//#Preview {
//    DayListView()
//}
 
