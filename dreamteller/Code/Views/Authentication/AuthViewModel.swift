//
//  AuthViewModel.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//


import Foundation
import SwiftUI
import FirebaseAuth

// -----------------------------
// 1) AuthService Protocol
// -----------------------------
protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> String
    func signUp(name: String, email: String, password: String) async throws -> String
    func signOut() async throws
    func currentUserId() -> String?
}

// -----------------------------
// 2) Real Firebase Auth Service
// -----------------------------
final class FirebaseAuthService: AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> String {
        let result: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error { continuation.resume(throwing: error); return }
                guard let uid = authResult?.user.uid else {
                    continuation.resume(throwing: AuthError.userNotFound); return
                }
                print("✅ Firebase signIn successful for UID: \(uid)")
                continuation.resume(returning: uid)
            }
        }
        return result
    }
    
    func signUp(name: String, email: String, password: String) async throws -> String {
        let result: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error { continuation.resume(throwing: error); return }
                guard let user = authResult?.user else {
                    continuation.resume(throwing: AuthError.userNotFound); return
                }
                // Update display name (optional)
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { profileError in
                    if let profileError = profileError {
                        // Not fatal for sign up; just log
                        print("DisplayName update failed: \(profileError.localizedDescription)")
                    }
                    continuation.resume(returning: user.uid)
                }
            }
        }
        return result
    }
    
    func signOut() async throws {
        do { try Auth.auth().signOut() } catch { throw error }
    }
    
    func currentUserId() -> String? { Auth.auth().currentUser?.uid }
}

// -----------------------------
// 2b) Simple Mock Auth Service (optional for previews/tests)
// -----------------------------
final class MockAuthService: AuthServiceProtocol {
    private var uid: String? = nil
    func signIn(email: String, password: String) async throws -> String {
        guard email.contains("@") else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.weakPassword }
        uid = "mock-\(UUID().uuidString.prefix(8))"
        return uid!
    }
    func signUp(name: String, email: String, password: String) async throws -> String {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { throw AuthError.invalidName }
        guard email.contains("@") else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.weakPassword }
        uid = "mock-\(UUID().uuidString.prefix(8))"
        return uid!
    }
    func signOut() async throws { uid = nil }
    func currentUserId() -> String? { uid }
}

// -----------------------------
// 3) Auth Errors
// -----------------------------
enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case invalidName
    case userNotFound
    case wrongPassword
    case emailAlreadyInUse
    case noCurrentUser
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please enter a valid email."
        case .weakPassword: return "Password must be at least 6 characters."
        case .invalidName: return "Please enter your name."
        case .userNotFound: return "User not found."
        case .wrongPassword: return "Incorrect password."
        case .emailAlreadyInUse: return "Email already in use."
        case .noCurrentUser: return "No authenticated user."
        case .unknown(let msg): return msg
        }
    }
}

private func mapFirebaseError(_ error: Error) -> AuthError {
    let nsError = error as NSError
    if let code = AuthErrorCode(rawValue: nsError.code) { // use enum directly
        switch code { // switch on AuthErrorCode
        case .invalidEmail: return .invalidEmail
        case .wrongPassword: return .wrongPassword
        case .userNotFound: return .userNotFound
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .weakPassword: return .weakPassword
        default: return .unknown(nsError.localizedDescription)
        }
    }
    return .unknown(nsError.localizedDescription)
}

// -----------------------------
// 4) AuthViewModel
// -----------------------------
@MainActor
final class AuthViewModel: ObservableObject {
    // Input fields
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    
    // UI state
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    @Published var userId: String? = nil
    @Published var displayName: String? = nil
    @Published var emailVerified: Bool = false
    @Published var idToken: String? = nil
    @Published var infoMessage: String? = nil // non-error feedback
    
    private let authService: AuthServiceProtocol
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init(authService: AuthServiceProtocol = FirebaseAuthService()) {
        self.authService = authService
        self.userId = authService.currentUserId()
        self.isAuthenticated = (self.userId != nil)
        beginAuthStateListening()
    }
    
    deinit {
        if let handle = authStateListenerHandle { Auth.auth().removeStateDidChangeListener(handle) }
    }
    
    private func beginAuthStateListening() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.userId = user?.uid
            self.isAuthenticated = (user != nil)
            if let user = user {
                self.displayName = user.displayName
                self.emailVerified = user.isEmailVerified
            } else {
                self.displayName = nil
                self.emailVerified = false
                self.idToken = nil
            }
        }
    }
    
    // MARK: - Validation
    private func validateSignUp() -> AuthError? {
        if name.trimmingCharacters(in: .whitespaces).isEmpty { return .invalidName }
        if !email.contains("@") { return .invalidEmail }
        if password.count < 6 { return .weakPassword }
        if password != repeatPassword { return .unknown("Passwords do not match.") }
        return nil
    }
    
    private func validateSignIn() -> AuthError? {
        if !email.contains("@") { return .invalidEmail }
        if password.count < 6 { return .weakPassword }
        return nil
    }
    
    // MARK: - Actions
    func signIn() async {
        errorMessage = nil
        if let validationError = validateSignIn() { errorMessage = validationError.localizedDescription; return }
        isLoading = true
        defer { isLoading = false }
        do {
            let uid = try await authService.signIn(email: email, password: password)
            userId = uid
            isAuthenticated = true
            print("✅ Signed in with UID: \(uid)")
        } catch let firebaseErr as NSError {
            errorMessage = mapFirebaseError(firebaseErr).localizedDescription
            print("❌ Sign in failed: \(errorMessage ?? "Unknown error")")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign in failed: \(error.localizedDescription)")
        }
    }
    
    func signUp() async {
        errorMessage = nil
        if let validationError = validateSignUp() { errorMessage = validationError.localizedDescription; return }
        isLoading = true
        defer { isLoading = false }
        do {
            let uid = try await authService.signUp(name: name, email: email, password: password)
            userId = uid
            isAuthenticated = true
        } catch let firebaseErr as NSError {
            errorMessage = mapFirebaseError(firebaseErr).localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signOut()
            userId = nil
            isAuthenticated = false
            name = ""
            email = ""
            password = ""
            repeatPassword = ""
        } catch let firebaseErr as NSError {
            errorMessage = mapFirebaseError(firebaseErr).localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func sendPasswordReset() async {
        errorMessage = nil
        infoMessage = nil
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, email.contains("@") else {
            errorMessage = AuthError.invalidEmail.localizedDescription
            return
        }
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error { continuation.resume(throwing: error); return }
                    continuation.resume(returning: ())
                }
            }
            infoMessage = "Password reset email sent."
        } catch {
            errorMessage = mapFirebaseError(error).localizedDescription
        }
    }
    
    func sendEmailVerification() async {
        errorMessage = nil
        infoMessage = nil
        guard let user = Auth.auth().currentUser else {
            errorMessage = AuthError.noCurrentUser.localizedDescription
            return
        }
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                user.sendEmailVerification { error in
                    if let error = error { continuation.resume(throwing: error); return }
                    continuation.resume(returning: ())
                }
            }
            infoMessage = "Verification email sent."
        } catch {
            errorMessage = mapFirebaseError(error).localizedDescription
        }
    }
    
    func reloadUser() async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                user.reload { error in
                    if let error = error { continuation.resume(throwing: error); return }
                    continuation.resume(returning: ())
                }
            }
            displayName = user.displayName
            emailVerified = user.isEmailVerified
            await fetchIDToken(forceRefresh: true)
        } catch {
            errorMessage = mapFirebaseError(error).localizedDescription
        }
    }
    
    func fetchIDToken(forceRefresh: Bool = false) async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            let token: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                user.getIDTokenForcingRefresh(forceRefresh) { token, error in
                    if let error = error { continuation.resume(throwing: error); return }
                    guard let token = token else {
                        continuation.resume(throwing: AuthError.unknown("Token missing")); return
                    }
                    continuation.resume(returning: token)
                }
            }
            idToken = token
        } catch {
            errorMessage = mapFirebaseError(error).localizedDescription
        }
    }
}

#if DEBUG
import SwiftUI
#Preview {
    let vm = AuthViewModel(authService: MockAuthService())
    return VStack(alignment: .leading, spacing: 12) {
        Text("Auth Preview (Mock)")
        Text("Authenticated: \(vm.isAuthenticated.description)")
        Button("Mock Sign In") { Task { await vm.signIn() } }
        Button("Mock Sign Up") { Task { await vm.signUp() } }
        Button("Send Reset") { Task { await vm.sendPasswordReset() } }
        if let err = vm.errorMessage { Text("Error: \(err)").foregroundColor(.red) }
        if let info = vm.infoMessage { Text(info).foregroundColor(.green) }
    }
    .padding()
}
#endif
