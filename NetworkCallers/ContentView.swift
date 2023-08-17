//
//  ContentView.swift
//  NetworkCallers
//
//  Created by duverney muriel on 26/07/23.
//

import SwiftUI

struct ContentView: View {
    @State private var users: GithubUser?
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: users?.avatarUrl ?? "")) { Image in
                Image
                    .resizable().scaledToFill().frame(width: 134,height: 134).clipShape(Circle())
                    .padding(.top,40)
            } placeholder: {
                Image(systemName: "applelogo").resizable().scaledToFill().frame(width: 134,height: 134)
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }

            
            Image(users?.avatarUrl ?? "image place holder")
                .padding()
            Text(users?.name ?? "name place holder").font(.title).fontWeight(.semibold)
            Text(users?.bio ?? "place holder")
            Spacer()
            
        }
        .padding()
        .task {
            do{
                users = try await getUsers()
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
    
    func getUsers() async throws -> GithubUser {
        let endpoint = "https://api.github.com/users/elduverx"
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data,response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubUser.self, from: data)
        } catch{
            throw GHError.invalidData
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum GHError: Error{
    case invalidURL
    case invalidName
    case invalidResponse
    case invalidData
}
