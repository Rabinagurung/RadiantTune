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
    
    var body: some View {
        VStack{
            TextField("Please enter station name", text: $name)
                 .padding(20)                .font(.system(size: 24, weight: .bold, design: .rounded))  // Set the font here
                 .foregroundColor(.red)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .onChange(of: name) { newValue in
                     print(name)
                 }
             TextField("Please enter station url", text: $url)
             .padding(20)                .font(.system(size: 24, weight: .bold, design: .rounded))  // Set the font here
             .foregroundColor(.red)
             .textFieldStyle(RoundedBorderTextFieldStyle())
    //         .onChange(of: name) { newValue in
    //             print(name)
    //         }
            Button(action: {
                print("name is \(name) url is \(url)")
            }, label: {
                Text("Confirm")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.blue)
                    .padding(20)
            })
    //        .background(.blue)
            .cornerRadius(10)
        }
    }
}

struct RTAddStationView_Previews: PreviewProvider {
    static var previews: some View {
        RTAddStationView()
    }
}
