//
//  RTAddStationView.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-06-15.
//

import SwiftUI

struct RTAddStationView: View {
    @State private var name = ""
    @State private var url = ""
    
    var isButtonEnable: Bool {
        return !name.isEmpty && !url.isEmpty
    }
    
    var body: some View {
        VStack{
            TextField("Please enter station name", text: $name)
                 .padding(20)                .font(.system(size: 24, weight: .bold, design: .rounded))  // Set the font here
                 .foregroundColor(.black)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .onChange(of: name) { newValue in
                     print(name)
                 }
             TextField("Please enter station url", text: $url)
             .padding(20)                .font(.system(size: 24, weight: .bold, design: .rounded))  // Set the font here
             .foregroundColor(.black)
             .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                let station = Station(changeuuid: "123", stationuuid: "343", name: name, url: url, favicon: "", country: "manual added", language: "manual added", tags: "manual added")
                RTDatabaseManager.shared.addFavorite(station: station)
                print("add successfully")
            }, label: {
                Text("Add")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .foregroundColor(isButtonEnable ? .white : .gray)
            })
            .disabled(!isButtonEnable)
            .cornerRadius(10)
            .frame(width: 100, height: 40)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct RTAddStationView_Previews: PreviewProvider {
    static var previews: some View {
        RTAddStationView()
    }
}
