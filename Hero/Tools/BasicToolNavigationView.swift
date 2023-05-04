//
//  BasicToolNavigationView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.05.23.
//

import SwiftUI

struct BasicToolNavigationView: View {
    
    let tool: Tool
    let object: SPTObject
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if let disclosedElementsData = model[object].disclosedElementsData {
                HStack {
                    ForEach(disclosedElementsData, id: \.id) { data in
                        HStack {
                            if data.id != disclosedElementsData.first!.id {
                                Image(systemName: "chevron.right")
                                    .imageScale(.large)
                                    .foregroundColor(.secondary)
                            }
                            VStack(alignment: .leading) {
                                Text(data.title)
                                    .fontWeight(.regular)
                                    .fixedSize()
                                if let substitle = data.subtitle {
                                    Text(substitle)
                                        .font(.system(.subheadline))
                                        .foregroundColor(Color.secondaryLabel)
                                        .fixedSize()
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                editingParams[tool: tool, object].activeElementIndexPath = data.indexPath
                            }
                        }
                    }
                }
            }
        }
    }
}
