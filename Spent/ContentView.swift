//
//  ContentView.swift
//  spent1
//
//  Created by Jakub Majka on 13/10/24.
//

import SwiftData
import SwiftUI
import Observation
import CoreLocation




struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    
    //@Query var spentItems: [SpentItem]
//    @Query(sort: \DayHistory.date, order: .reverse) var spentItemsPerDay: [DayHistory]
    @StateObject var locationManager = LocationManager()
    @State var showingAddSheet = false
    
    var currentMonthTotal: Double {(try? getMonthTotal(using: modelContext, currentMonth: getCurrentMonthNumber())) ?? 0 }
    var previousMonthTotal: Double {(try? getMonthTotal(using: modelContext, currentMonth: getPreviousMonth(month: getCurrentMonthNumber()))) ?? 0}
   
    @State var position: CGFloat =  120
    
    var body: some View{
        NavigationStack{
           
            ZStack{
                
                DayListView(position: $position)
                    
                
                VStack(alignment: .leading,spacing: 0){
                
                    VStack(alignment: .leading,spacing: 0){
                    
                        HStack(alignment: .top){
                        
                            Text(currentMonthTotal.toCurrency)
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                                .font(.system(size: 45))
                            
                            Spacer()
                            
                            Button("", systemImage: "plus"){
                                showingAddSheet.toggle()
                            }
                            .padding(15)
                            .font(.system(size: 25))
                            .sheet(isPresented: $showingAddSheet){
                                NewItemButtonView()
                                    .presentationDetents([.fraction(0.45)])
                                    .presentationDragIndicator(.hidden)
                            }
                        }
                        
                        (Text("So far spent") +
                         getChangeIcon(currentTotal: currentMonthTotal, previousTotal: previousMonthTotal ) +
                         Text((try? changePercentages(currentTotal: currentMonthTotal, previousTotal: previousMonthTotal)) ?? 0, format: .number)  +
                         Text("% this month"))
                        .font(.subheadline).foregroundStyle(.gray).opacity(previousMonthTotal != 0 ? 1 : 0)
                        
                    }
                    .padding(.leading, 15)
                    .opacity(position < 70 ? (Double(position)/100) : 1)

                    Spacer()
                }
            }
        }
        .environmentObject(locationManager)
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: SpentItem.self, inMemory: true)
//}
