//
//  ContentView.swift
//  ArtilleryTest
//
//  Created by Ben Gottlieb on 3/19/20.
//  Copyright © 2020 Ben Gottlieb. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var authManager: FirebaseAuthManager
	
	@State var email = ""
	@State var password = ""

	var body: some View {
		VStack() {
			if authManager.isSignedIn {
				VStack() {
					Text("Signed in as: ")
					Text(self.authManager.userEmail ?? "No email")
					
					Button(action: {
						self.authManager.signOut()
					}) {
						Text("Sign Out")
					}
				}
				.padding()

			} else {
				TextField("Email", text: $email)
					.padding()

				TextField("Password", text: $password)
					.padding()

				Button(action: {
					self.authManager.signIn(with: self.email, password: self.password)
				}) { Text("Sign In with Email") }
				.padding()

				Button(action: {
					self.authManager.signInWithApple()
				}) { Text("Sign In with Apple") }
				.padding()

				Button(action: {
					self.authManager.signInWithGoogle()
				}) { Text("Sign In with Google") }
				.padding()

				if authManager.signinError != nil {
					Text(authManager.signinError!.localizedDescription)
						.padding()
						.multilineTextAlignment(.center)
						.lineLimit(nil)
						.foregroundColor(.red)
						
				}
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
