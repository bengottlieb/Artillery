//
//  FirebaseAuthManager.swift
//  ArtilleryTest
//
//  Created by Ben Gottlieb on 3/20/20.
//  Copyright © 2020 Ben Gottlieb. All rights reserved.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import GoogleSignIn
import Suite

public class FirebaseAuthManager: NSObject, ObservableObject {
	public static let instance = FirebaseAuthManager()
	
	private var listenerHandle: AuthStateDidChangeListenerHandle?
	@Published var user: User?
	@Published var signinError: Error?
	@Published var isSignedIn = false
	
	var currentNonce: String?
	var userEmail: String? { self.user?.email }
	
	override init() {
		super.init()
		FirebaseApp.configure()
		self.listenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
			self.user = user
			self.isSignedIn = user != nil
		}
	}
	
	public func handle(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
		if GIDSignIn.sharedInstance().handle(url) { return true }
		
		return false
	}
	
	public func signOut() {
		self.isSignedIn = false
		do {
			try Auth.auth().signOut()
		} catch {
			print ("Error signing out: %@", error)
		}
	}
	
	
	public func signIn(with email: String, password: String) {
		Auth.auth().signIn(withEmail: email, password: password) { result, error in
			if let err = error {
				self.signinError = err
				self.isSignedIn = false
			} else if let user = result?.user {
				self.user = user
				self.isSignedIn = true
			}
		}
	}
}


extension FirebaseAuthManager: GIDSignInDelegate {
	public func signInWithGoogle(from viewController: UIViewController? = UIApplication.shared.currentScene?.windows.first?.rootViewController) {

		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

		GIDSignIn.sharedInstance()?.presentingViewController = viewController
		GIDSignIn.sharedInstance().signIn()
	}


	public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if error != nil { self.signinError = error }
		guard let auth = user.authentication else { return }

		let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
		Auth.auth().signIn(with: credentials) { result, error in
			if let user = result?.user {
				self.user = user
				self.isSignedIn = true
			} else {
				self.signinError = error
			}
		}
	}

	public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		self.isSignedIn = false
	}
}
