//
//  ChartsContainer.swift
//  Step Tracker
//
//  Created by Victor Marquez on 4/7/24.
//

import SwiftUI

struct ChartContainerConfiguration {
    let title:    String
    let symbol:   String
    let subTitle: String
    let isNav:    Bool
    let context:  HealthMetricContext
}

struct ChartsContainer<Content: View>: View {
    
    let config:ChartContainerConfiguration
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            if config.isNav {
                navigstionLinkView
            } else {
                titleView
            }
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var navigstionLinkView: some View {
        NavigationLink(value: config.context) {
            HStack{
              titleView
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            
        }.foregroundColor(.secondary)
         .padding(.bottom, 12)
    }
    
    var titleView: some View {
        VStack(alignment:.leading){
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(config.context == .steps ? .pink : .indigo)
            
            Text(config.subTitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
        
}

#Preview {
    ChartsContainer(config: .init(title: "Test Title", symbol: "figure.walk", subTitle: "Test Subtitle", isNav: true, context: .steps)){
        Text("chart")
            .frame(minHeight: 150)
    }
}
