//
//  FirebaseAuthManager+Apple.swift
//  ArtilleryTest
//
//  Created by Ben Gottlieb on 3/21/20.
//  Copyright © 2020 Ben Gottlieb. All rights reserved.
//

import UIKit
import Suite
import FirebaseCore
import AuthenticationServices
import CryptoKit
import FirebaseAuth

extension FirebaseAuthManager {
	public func signInWithApple(from viewController: UIViewController? = UIApplication.shared.currentScene?.windows.first?.rootViewController) {
		self.currentNonce = String.randomNonce()
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		request.nonce = sha256(self.currentNonce!)
		
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}
	
	private func sha256(_ input: String) -> String {
		let inputData = Data(input.utf8)
		let hashedData = SHA256.hash(data: inputData)
		let hashString = hashedData.compactMap {
			return String(format: "%02x", $0)
		}.joined()
		
		return hashString
	}
}

extension FirebaseAuthManager: ASAuthorizationControllerDelegate {
	public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
			guard let nonce = currentNonce else {
				fatalError("Invalid state: A login callback was received, but no login request was sent.")
			}
			guard let appleIDToken = appleIDCredential.identityToken else {
				print("Unable to fetch identity token")
				return
			}
			guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
				print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
				return
			}
			
			let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
			Auth.auth().signIn(with: credential) { authResult, error in
				self.signinError = error
			}
		}
	}
}

extension FirebaseAuthManager: ASAuthorizationControllerPresentationContextProviding {
	public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return UIApplication.shared.currentScene!.windows.first!
	}
	
	
	
}
