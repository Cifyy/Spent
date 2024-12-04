//
//  NewItemButtonView.swift
//  spent1
//
//  Created by Jakub Majka on 14/10/24.
//

import SwiftUI
import CoreLocation
import SwiftData

func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async -> String{
     let geocoder = CLGeocoder()
     let location = CLLocation(latitude: latitude, longitude: longitude)
 
     do {
         let placemarks = try await geocoder.reverseGeocodeLocation(location)
         if let placemark = placemarks.first {
             if let address = placemark.name {
                 return address
                 
             } else {
                 return "No familiar name"
             }
         } else {
             return "No familiar name"
         }
     } catch {
         return "No familiar name"
     }

 }
func getSymbol(forCurrencyCode code: String) -> String {
   let locale = NSLocale(localeIdentifier: code)
    return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code) ?? "$"
}

struct NewItemButtonView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var locationManager: LocationManager
    
    private enum Field: Int, CaseIterable {
        case category, amountField, location, date
    }
    @State private var selectedCategory: spentCategory = .other
    @State private var amount: Double?
    @State private var date: Date = Date.now
    @State var locationSetting: String = "Current"
    
    @FocusState private var focusedField: Field?
    @State private var iconWidth: Double = 0

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            List {
                
                Picker("Category", selection: $selectedCategory){
                    ForEach(spentCategory.allCases){ option in
                        HStack{
                            categorySymbols.image(name: option.rawValue)
                                .sync(with: $iconWidth)
                                .frame(width: iconWidth)
                            Text(String(describing: option).capitalized)
                        }
                    }
                    
                }
                .onPreferenceChange(SymbolWidthPreferenceKey.self) { iconWidth = $0 }
                //.pickerStyle(NavigationLinkPickerStyle())
                .focused($focusedField, equals: .category)
                
                HStack{
                    Text(amount == nil ? "" : getSymbol(forCurrencyCode: Locale.current.currency?.identifier ?? "USD") )
                    TextField("Transaction amount", value: $amount, formatter: formatter)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amountField)
                        .offset(x: -8)
                }
                
                DatePicker("Transaction Date", selection: $date, in: ...Date())
                    .focused($focusedField, equals: .date)
                
                
//                NavigationLink{
//                    Text("siema")
//                } label: {
//                    HStack{
//                        Text("Location")
//                        Spacer()
//                        Text(locationManager.locationPermission ? locationSetting : "No permission").opacity(0.5)
//                    }
//                }
                HStack{
                    Text("Location")
                    Spacer()
                    Text(locationManager.locationPermission ? locationSetting : "No permission").opacity(0.5)
                }
                .toolbar{
                    ToolbarItemGroup(placement: .keyboard){
                        Spacer()
                        Button("Done"){ focusedField = nil }
                    }
                    ToolbarItem(placement: .navigation){
                        Text("New Expense")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.leading, 10)
                            .offset(y: 15)
                    }
                    ToolbarItem(placement: .confirmationAction){
                        Button("Add"){
                            if amount == nil || amount == 0.0 { return }
                            Task{ await addExpense() }
                            dismiss()
                        }
                        .disabled(amount == nil || amount == 0.0)
                    }
                }
            }
            
            .onAppear(perform: {
                locationManager.manager.requestWhenInUseAuthorization()
            })
            .scrollDisabled(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
        }

    }
    
}

//#Preview {
//    NewItemButtonView()
//        .modelContainer(for: SpentItem.self, inMemory: true)
//        .environmentObject(LocationManager())
//    
//}

extension NewItemButtonView{
    


    enum idLookup: Error{
        case noMatchingID
    }
    func getIDS(date: Date) throws -> PersistentIdentifier {
        
        let predicate = #Predicate<DayHistory> { $0.date == date }
        let request = FetchDescriptor(predicate: predicate)
        let id = try modelContext.fetchIdentifiers(request)
        
        if id.count == 0 { throw idLookup.noMatchingID }
        return id[0]
    }

    func addExpense() async {
        
        var location: CLLocationCoordinate2D
        do{
            location = try await locationManager.checkAuthorization()
            print(String(location.latitude ))
        }
        catch{
            location = CLLocationCoordinate2D(latitude: -1, longitude: -1)
        }

        let keyDate = Calendar.current.startOfDay(for: date)
        let friendlyName = await reverseGeocoding(latitude: location.latitude, longitude: location.longitude)
        
        do{
            let id = try getIDS(date: keyDate)
            
            if let dateEntity = modelContext.model(for: id) as? DayHistory {
                let spentInstance = SpentItem(
                    category: selectedCategory,
                    amount: amount ?? 0,
                    precisedate: date,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    friendlyName: friendlyName,
                    dayCategory: dateEntity)
                
                dateEntity.spentItems.append(spentInstance)
                modelContext.insert(spentInstance)
                
            }else{
                print("!Error getting DayHistory entity for id")
            }
        
        }
        catch idLookup.noMatchingID{
            
            let dateEntity = DayHistory(date: keyDate)
            let spentInstance = SpentItem(
                category: selectedCategory,
                amount: amount ?? 0,
                precisedate: date,
                latitude: location.latitude,
                longitude: location.longitude,
                friendlyName: friendlyName,
                dayCategory: dateEntity)
            
            dateEntity.spentItems.append(spentInstance)
            modelContext.insert(spentInstance)
            modelContext.insert(dateEntity)
            
        }
        catch{
            print("!Error while fetching dayEntity id")
        }
    }

}
