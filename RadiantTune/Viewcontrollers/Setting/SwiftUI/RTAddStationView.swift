//
//  RTAddStationView.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-06-15.
//

import SwiftUI

var logoArray = [
    "music.quarternote.3",
    "music.mic",
    "command",
    "house.lodge.fill",
    "pianokeys",
    "graduationcap",
    "sun.dust"
]

struct RTAddStationView: View {
    @State private var name = ""
    @State private var url = ""
    @State private var logoColor: Color = .black
    @State private var currentIndex = 0
    
    
    var isButtonEnable: Bool {
        return !name.isEmpty && isValidURLString(url: url)
    }
    
    var isValidStation: Bool {
        return !RTDatabaseManager.shared.isFavoriteStation(uuid: base64String(originalString: url)!)
    }
    
    var body: some View {
        VStack{
            let logoName = logoArray[currentIndex]
            Image(systemName: logoName)
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .background(logoColor)
            HStack {
                Button {
                    currentIndex = (currentIndex + 1) % logoArray.count
                } label: {
                    Text("logo")
                }
            }
            TextField("Please enter station name", text: $name)
                .clearButton(text: $name)
                 .padding(20)
                 .font(.system(size: 24, weight: .bold, design: .rounded))
                 .foregroundColor(.black)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .submitLabel(.done)
             TextField("Please enter station url", text: $url)
                .clearButton(text: $url)
             .padding(20)
             .font(.system(size: 24, weight: .bold, design: .rounded))
             .foregroundColor(.black)
             .textFieldStyle(RoundedBorderTextFieldStyle())
             .submitLabel(.done)
            Button(action: {
                if isValidStation {
                    let station = Station(changeuuid: "manual", stationuuid: base64String(originalString: url)!, name: name, url: url, favicon: logoName, country: "manual added", language: "manual added", tags: "manual added")
                    RTDatabaseManager.shared.addFavorite(station: station)
                    showHUDWithSuccess(message: "Add successfully")
                    // refresh favorite page
                    NotificationCenter.default.post(name: NSNotification.Name(Constants.FavoritesUpdated), object: nil)
                } else {
                    showHUDWithError(message: "Already exist")
                }

            }, label: {
                Text("Add")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .foregroundColor(isButtonEnable ? .white : Color(UIColor.lightGray))
            })
            .frame(width: 150, height: 45)
            .background(isButtonEnable ? .blue : .gray)
            .disabled(!isButtonEnable)
            .cornerRadius(10)
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
