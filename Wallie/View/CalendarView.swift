//
//  Untitled.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct CalendarView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(WallieViewModel.self) var viewModel
    
    var body: some View {
        Text("Calendario")
    }
}

#Preview {
    CalendarView()
        .environment(WallieViewModel())
}
