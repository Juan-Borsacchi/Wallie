////
////  MomentsView.swift
////  Wallie
////
////  Created by Vitor Silva Souza on 16/08/26.
////

//import SwiftUI
//
//struct MomentsView : View {
//    @State private var displaySheet = false
//    
//    @Environment(\.managedObjectContext) var viewContext
//    @Environment(WallieViewModel.self) var viewModel
//    
//    var body: some View {
//        NavigationStack {
//            
//            ZStack {
//                Image("BackgroundMoments")
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//                
//                VStack (alignment: .center) {
//                    HStack {
//                        Title(title: "Momentos", subtitle: "")
//                            .foregroundStyle(Color.white)
//                    }
//                    .padding(.bottom, 50)
//                    
//                    //!!!!
//                    //ADICIONAR O CARROSEL OU LIVRO AQUI!!!!!!!!!!
//                    //!!!!
//                    
//                    AddMoment(displaySheet: $displaySheet)
//                }
//                .padding(16)
//                .sheet(isPresented: $displaySheet) {
//                    CreateMomentView()
//                        .environment(\.managedObjectContext, viewContext)
//                        .presentationDragIndicator(.visible)
//                        .presentationDetents([.large])
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    MomentsView()
//        .environment(WallieViewModel())
//        // Para o core data no futuro:
//        //.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
