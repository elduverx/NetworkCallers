//
//  MoreInfoView.swift
//  NetworkCallers
//
//  Created by duverney muriel on 26/07/23.
//

import SwiftUI

struct MoreInfoView: View {
    
    @State private var followers: InfoViewModel?
    var body: some View {
      
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: followers?.avatarUrl ?? "")) { image in
                image
                    .resizable().scaledToFill().frame(width: 30, height: 30).clipShape(Circle())
                    .padding(.top, 40)
            } placeholder: {
                Image(systemName: "applelogo").resizable().scaledToFill().frame(width: 134,height: 134)
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }
            Image(followers?.avatarUrl ?? " ").padding()
            Text(followers?.name ?? "name holder")
        

        }.padding(20)
            .task {
                do{
                    followers = try await getUsers()
                }catch GHError.invalidData {
                    print("invalid data error")
                }catch GHError.invalidName {
                    print("invalid name error")
                }catch GHError.invalidResponse {
                    print("invalid response error")
                }catch GHError.invalidURL {
                    print("invalid url error")
                }catch {
                    print("unexpected error")
                }
            }
    }
    
    func getUsers() async throws -> InfoViewModel {
        
        let endpoint = " https://api.github.com/users/elduverx"
        guard let url = URL(string: endpoint) else {
            throw MGError.invalidURL
        }
        let (data,response) = try await URLSession.shared.data(from: url)
        guard let response = response as?  HTTPURLResponse, response.statusCode == 200 else{
            throw MGError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(InfoViewModel.self, from: data)
        } catch  {
            throw MGError.invalidData
        }
    
        
    }
    
}

struct MoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MoreInfoView()
    }
}


enum MGError: Error{
    case invalidURL
    case invalidName
    case invalidResponse
    case invalidData
}
