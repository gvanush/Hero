//
//  AssetSelection.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI



struct TestView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Text("Test")
            .navigationBarTitle("Select asset", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {Image(systemName: "chevron.left")})
    }
}

/*struct SelectInputSourceView: View {

    @Environment(\.presentationMode) var presentationMode
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(AssetSource.allCases, id: \.self) { assetSource in
                    HStack {
                        if assetSource.hasMultipleOptions {
                            NavigationLink(destination: ImagePicker(image: $image)) {
                                Text(assetSource.name)
                            }
                        } else {
                            Text(assetSource.name)
                        }
                        
                    }.tag(assetSource)
                }
            }
            .navigationBarTitle("Select asset", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {Text("Cancel")})
        }
    }
}*/
