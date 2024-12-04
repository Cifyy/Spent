//
//  SpentItemView.swift
//  spent1
//
//  Created by Jakub Majka on 20/11/24.
//

import SwiftUI
import MapKit


struct SpentItemView: View {
    @Environment(\.modelContext) var modelContext
    var spentItem: SpentItem
    
    private var location: CLLocationCoordinate2D {CLLocationCoordinate2D(latitude: spentItem.latitude, longitude: spentItem.longitude)}
    private var region: MKCoordinateRegion { MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: spentItem.latitude, longitude: spentItem.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))}
    private var cameraPosition: MapCameraPosition { MapCameraPosition.region(region) }


    var body: some View {

        VStack(alignment: .leading, spacing: 0){
//            HStack(alignment: .center, spacing: 5){
            Text(spentItem.amount.toCurrency)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .font(.system(size: 45))
            HStack(spacing: 1){
                Text(spentItem.category.rawValue.capitalized)
                categorySymbols.image(name: spentItem.category.rawValue)

            }
            .offset(y: -4)
            .foregroundStyle(.gray)
            .font(.system(size: 15))
            .padding(.bottom, 20)
            .padding(.leading, 5)
            
            Text(spentItem.precisedate.formatted(
                    .dateTime
                    .weekday(.wide)
                    .day(.defaultDigits)
                    .month(.defaultDigits)
                    .year(.defaultDigits)
                    .hour(.defaultDigits(amPM:  Date.FormatStyle.Symbol.Hour.AMPMStyle.wide))
                    .minute(.defaultDigits)
            ))
            .font(.subheadline)
            .foregroundStyle(.gray)
            .fontWeight(.regular)
            .padding(5)
                 
            
            VStack(alignment: .leading,spacing: 0){
                
                Map(position: .constant(cameraPosition), bounds: nil, interactionModes: [], scope: nil){
                    Marker(coordinate: location, label: {})
                }
                .frame(height: 200)
                
                Text(spentItem.friendlyName).padding(10)
            }

            .background(.ultraThickMaterial)
            .cornerRadius(15)
            Spacer()
        }
        .padding(.top, 15)
        .padding([.leading,.trailing], 10)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
//
//#Preview {
//    SpentItemView()
//}
