/*
MIT License
Copyright (c) [2020] Extreme Viet Nam

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
import Amplify
import AmplifyPlugins
import AWSPluginsCore

enum AmplifyErrorCode : String {
    case resourceNotFound = "ResourceNotFoundException"
    case invalidParameter = "InvalidParameterException"
    case unexpectedLambda = "UnexpectedLambdaException"
    case userLambdaValidation = "UserLambdaValidationException"
    case notAuthorized = "NotAuthorizedException"
    case invalidPassword = "InvalidPasswordException"
    case usernameExist = "UsernameExistsException"
    case codeDeliveryFailure = "CodeDeliveryFailureException"
    case tooManyFailedAttemps = "TooManyFailedAttemptsException"
    case codeMismatch = "CodeMismatchException"
    case expiredCode = "ExpiredCodeException"
    case invalidLambdaResponse = "InvalidLambdaResponseException"
    case aliasExists = "AliasExistsException"
    case tooManyRequests = "TooManyRequestsException"
    case limitExceeded = "LimitExceededException"
    case userNotFound = "UserNotFoundException"
    case internalError = "InternalErrorException"
    case amazonClient = "AmazonClientException"
    case amazonService = "AmazonServiceException"
    case defaultException = "DefaultException"
    case userNotConfirm = "UserNotConfirm"
    case mfaMethodNotFound = "MFAMethodNotFound"
    case softwareTokenMFANotEnabled = "SoftwareTokenMFANotEnable"
    case passwordResetRequired = "PasswordResetRequired"
    case deviceNotTracked = "DeviceNotTrack"
    case errorLoadingUI = "ErrorLoadingUU"
    case userCancelled = "UserCancel"
    case invalidAccountTypeException = "InvalidAccountTypeException"
    case network = "NetworkException"
    case api = "ApiException"
    case configuration = "ConfigurationException"
    case validation = "ValidationException"
    case sessionExpired = "SessionExpiredException"
    case signedOut = "SignedOutException"
    case invalidState = "InvalidStateException"
    case unknown = "UnknownException"
}

class SwiftFlutterAmplifySDK {
    
    static func initialize(result: @escaping FlutterResult) {
        print("\n============ initialize ==============\n\n")
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
            print("Amplify configured with storage plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
    
    // sign up
    static func signUp(result: @escaping FlutterResult, username: String, password: String, userAttributes: [String: String]) {
        print("\n============ signUp ==============\n\n")
        
        var attributes: [AuthUserAttribute] = []
        for key in userAttributes.keys {
            switch key {
            case "email":
                attributes.append(AuthUserAttribute(.email, value: userAttributes[key] ?? ""))
                break
            case "phone":
                attributes.append(AuthUserAttribute(.phoneNumber, value: userAttributes[key] ?? ""))
                break
            case "name":
                attributes.append(AuthUserAttribute(.name, value: userAttributes[key] ?? ""))
                break
            default:
                break
            }
        }
        
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        _ = Amplify.Auth.signUp(username: username, password: password, options: options) { signupResult in
            switch signupResult {
            case .success(let rs):
                var isSignUpComplete: Bool
                if case let .confirmUser(deliveryDetails, _) = rs.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                    isSignUpComplete = false
                } else {
                    print("SignUp Complete")
                    isSignUpComplete = true
                }
                
                DispatchQueue.main.async {
                    result([
                        "isSignUpComplete": isSignUpComplete,
                    ])
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    // confirm sign up
    static func confirmSignUp(result: @escaping FlutterResult, username: String, confirmationCode: String) {
        print("\n============ confirmSignUp ==============\n\n")
        
        _ = Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { signUpResult in
            switch signUpResult {
            case .success(_):
                print("Confirm signUp succeeded")
                DispatchQueue.main.async {
                    result([
                        "isSignUpComplete": true,
                    ])
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    // signin
    static func signIn(result: @escaping FlutterResult, username: String, password: String) {
        print("\n============ signIn ==============\n\n")
        
        _ = Amplify.Auth.signIn(username: username, password: password) { resultSignIn in
            switch resultSignIn {
            case .success(let authSigninResult):
                print("Sign in succeeded")
                DispatchQueue.main.async {
                    result([
                        "isSignInComplete": authSigninResult.isSignedIn,
                        "authSignInStep": SwiftFlutterAmplifySDK.convertAuthSignInStep(authSignInStep: authSigninResult.nextStep)
                    ])
                }
            case .failure(let error):
                print("Sign in failed \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    // resend signup code
    static func resendSignUpCode(result: @escaping FlutterResult, username: String) {
        print("\n============ resendSignUpCode ==============\n\n")
        
        _ = Amplify.Auth.resendSignUpCode(for: username) { resultResendCode in
            switch resultResendCode {
            case .success(_):
                print("Resend code succeeded")
                DispatchQueue.main.async {
                    result([
                        "isSignUpComplete": true
                    ])
                }
                break
            case .failure(let error):
                print("Resend code failed \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    // reset password
    static func resetPassword(result: @escaping FlutterResult, username: String) {
        print("\n============ resetPassword ==============\n\n")
        
        _ = Amplify.Auth.resetPassword(for: username) { resetResult in
            var isPasswordReset: Bool
            do {
                let rs = try resetResult.get()
                switch rs.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
                    isPasswordReset = false
                case .done:
                    print("Reset completed")
                    isPasswordReset = true
                }
                DispatchQueue.main.async {
                    result([
                        "isPasswordReset": isPasswordReset
                    ])
                }
            } catch {
                print("Reset password failed with error \(error)")
                if let err = error as? AmplifyError {
                    SwiftFlutterAmplifySDK.handlerErrorAuthException(error: err, result: result)
                }
            }
        }
    }
    
    // confirm reset password
    static func confirmResetPassword(result: @escaping FlutterResult, username: String, newPassword: String, confirmationCode:String) {
        print("\n============ confirmResetPassword ==============\n\n")
        
        _ = Amplify.Auth.confirmResetPassword(for: username, with: newPassword, confirmationCode: confirmationCode) { resultConfirm in
            switch resultConfirm {
            case .success:
                print("Password reset confirmed")
                DispatchQueue.main.async {
                    result(true)
                }
            case .failure(let error):
                print("Reset password failed with error \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    //change password
    static func changePassword(result: @escaping FlutterResult, oldPassword: String, newPassword: String) {
        print("\n============ changePassword ==============\n\n")
        
        _ = Amplify.Auth.update(oldPassword: oldPassword, to: newPassword) { changePassResult in
            switch changePassResult {
            case .success:
                print("Change password succeeded")
             DispatchQueue.main.async {
                 result(true)
             }
            case .failure(let error):
             print("Change password failed with error \(error)")
             SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    // logout
    static func signOut(result: @escaping FlutterResult) {
        print("\n============ signOut ==============\n\n")
        
        _ = Amplify.Auth.signOut() { signoutResult in
            switch signoutResult {
            case .success:
                print("Successfully signed out")
                DispatchQueue.main.async {
                    result(true)
                }
            case .failure(let error):
                print("Sign out failed with error \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
                }
            }
    }
    
    // logout globally
    static func globalSignOut(result: @escaping FlutterResult) {
        print("\n============ globalSignOut ==============\n\n")
        
        let options = AuthSignOutRequest.Options(globalSignOut: true)
        _ = Amplify.Auth.signOut(options: options) { signoutResult in
            switch signoutResult {
            case .success:
                print("Successfully signed out")
                DispatchQueue.main.async {
                    result(true)
                }
            case .failure(let error):
                print("Sign out failed with error \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
                }
            }
    }
    
    // Get cognito user pool token
    static func getTokens(result: @escaping FlutterResult) {
        print("\n============ getTokens ==============\n\n")
        
        _ = Amplify.Auth.fetchAuthSession { rs in
            do {
                let session = try rs.get()

                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                    print("Id token - \(tokens.idToken) ")
                    print("Access token - \(tokens.accessToken)")
                    print("Refresh token - \(tokens.refreshToken)")
                    
                    DispatchQueue.main.async {
                        result([
                            "idToken": tokens.idToken,
                            "accessToken": tokens.accessToken,
                            "refreshToken": tokens.refreshToken
                        ])
                    }
                }
            } catch {
                print("Fetch auth session failed with error - \(error)")
                if let err = error as? AmplifyError {
                    SwiftFlutterAmplifySDK.handlerErrorAuthException(error: err, result: result)
                }
            }
        }
    }
    
    // Get aws credentials
    static func getCredentials(result: @escaping FlutterResult) {
        print("\n============ getCredentials ==============\n\n")
        
        _ = Amplify.Auth.fetchAuthSession { rs in
            do {
                let session = try rs.get()
                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                    let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                    print("Access key - \(credentials.accessKey) ")
                    print("Secret key - \(credentials.secretKey)")
                    DispatchQueue.main.async {
                        result([
                            "accessKeyId": credentials.accessKey,
                            "secretKey": credentials.secretKey
                        ])
                    }
                }
            } catch {
                print("Fetch auth session failed with error - \(error)")
                if let err = error as? AmplifyError {
                    SwiftFlutterAmplifySDK.handlerErrorAuthException(error: err, result: result)
                }
            }
        }
    }
    
    // Get user identity id
    static func getIdentityId(result: @escaping FlutterResult) {
        print("\n============ getIdentityId ==============\n\n")
        
        _ = Amplify.Auth.fetchAuthSession { rs in
            do {
                let session = try rs.get()
             
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    let identityId = try identityProvider.getIdentityId().get()
                    print("Identity id \(identityId)")
                    DispatchQueue.main.async {
                        result(identityId)
                    }
                }
            } catch {
                print("Fetch auth session failed with error - \(error)")
                if let err = error as? AmplifyError {
                    SwiftFlutterAmplifySDK.handlerErrorAuthException(error: err, result: result)
                }
            }
        }
    }
    
    // check user is signed in
    static func isSignedIn(result: @escaping FlutterResult) {
        print("\n============ isSignedIn ==============\n\n")
        
        _ = Amplify.Auth.fetchAuthSession { rs in
            do {
                let session = try rs.get()
                DispatchQueue.main.async {
                    result(session.isSignedIn)
                }
                
            } catch {
                print("Fetch auth session failed with error - \(error)")
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    // get name of current user
    static func getUsername(result: @escaping FlutterResult) {
        print("\n============ getUsername ==============\n\n")
        
        if let currentUser = Amplify.Auth.getCurrentUser() {
            DispatchQueue.main.async {
                result(currentUser.username)
            }
        }
    }
    
    // authentication with social network (Google, Apple)
    static func authenWithSocialNetwork(result: @escaping FlutterResult, authorProvider: AuthProvider) {
        guard let keyWindow = UIWindow.key else { return }
        
        _ = Amplify.Auth.signInWithWebUI(for: authorProvider, presentationAnchor: keyWindow) { rs in
            switch rs {
            case .success( let data):
                print("Sign in succeeded \(data.nextStep)")
                DispatchQueue.main.async {
                    result(data.isSignedIn)
                }
            case .failure(let error):
                print("Sign in failed \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    //MARK: Attribute
    static func updatePhone(_ phone: String, result: @escaping FlutterResult) {
        _ = Amplify.Auth.update(userAttribute: AuthUserAttribute(.phoneNumber, value: phone)) {
            do {
                let updateResult = try $0.get()
                let isUpdateAttributeCompleted: Bool
                
                switch updateResult.nextStep {
                case .confirmAttributeWithCode(let deliveryDetails, let info):
                    print("Confirm the attribute with details send to - \(deliveryDetails) \(String(describing: info))")
                    isUpdateAttributeCompleted = false
                case .done:
                    isUpdateAttributeCompleted = true
                }
                result(isUpdateAttributeCompleted)
            } catch {
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    static func confirmPhone(code: String, result: @escaping FlutterResult) {
        _ = Amplify.Auth.confirm(userAttribute: .phoneNumber, confirmationCode: code) {
            switch $0 {
            case .success:
                result(true)
            case .failure(let error):
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    static func resendConfirmPhoneCode(result: @escaping FlutterResult) {
        _ = Amplify.Auth.resendConfirmationCode(for: .phoneNumber) {
            switch $0 {
            case .success(let deliveryDetails):
                print("Resend code send to - \(deliveryDetails)")
                result(true)
            case .failure(let error):
                print("Resend code failed with error \(error)")
                SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
            }
        }
    }
    
    //MARK: Call API
    
    static func requestAPI(name: String? = nil, path: String, method: ApiMethod, token: String? = nil, params: [String: Any]? = nil, result: @escaping FlutterResult) {
        print("\n============ Call \(method) API ==============\n\n")
        var headers = ["Content-Type": "application/json"]
        
        if let tokenStr = token, !tokenStr.isEmpty {
            headers["Authorization"] = tokenStr
        }
        
        var data: Data?
        if let pr = params {
            data = try? JSONSerialization.data(withJSONObject: pr, options: [])
        }
        
        let request = RESTRequest(apiName: name, path: path, headers: headers, body: data)
        
        switch method {
        case .get:
            _ = Amplify.API.get(request: request) {
                handlerResponse(response: $0, result: result)
            }
        case .post:
            _ = Amplify.API.post(request: request) {
                handlerResponse(response: $0, result: result)
            }
        case .delete:
            _ = Amplify.API.delete(request: request) {
                handlerResponse(response: $0, result: result)
            }
        case .put:
            _ = Amplify.API.put(request: request) {
                handlerResponse(response: $0, result: result)
            }
        }
    }
    
    static func handlerResponse(response: (AmplifyOperation<RESTOperationRequest, Data, APIError>.OperationResult), result: @escaping FlutterResult) {
        switch response {
        case .success(let data):
            result(String(decoding: data, as: UTF8.self))
            
        case .failure(let error):
            switch error {
            case .httpStatusError(let statuscode, let response):
                print("statuscode = \(statuscode) ==== res  \(response)")
            default:
                print("No Description")
            }
            SwiftFlutterAmplifySDK.handlerErrorAuthException(error: error, result: result)
        }
    }
    
    static func handlerErrorAuthException(error: Error, result:  @escaping FlutterResult) {
        var errorCode: AmplifyErrorCode?
        var errorDescription: String?
        
        if let authError = error as? AuthError {
            errorCode = authError.errorCode
            errorDescription = authError.errorDescription
        } else if let apiError = error as? APIError {
            errorCode = apiError.errorCode
            errorDescription = apiError.errorDescription
        }
        
        result(FlutterError(code: (errorCode ?? .defaultException).rawValue, message: errorDescription ?? "", details: errorDescription ?? ""))
    }
    
    // MARK: Private functions
    private static func convertAuthSignInStep(authSignInStep: AuthSignInStep) -> String {
        switch authSignInStep {
        case .confirmSignInWithSMSMFACode(_, _):
            return "CONFIRM_SIGN_IN_WITH_SMS_MFA_CODE"
        case .confirmSignInWithCustomChallenge(_):
            return "CONFIRM_SIGN_IN_WITH_CUSTOM_CHALLENGE"
        case .confirmSignInWithNewPassword(_):
            return "CONFIRM_SIGN_IN_WITH_NEW_PASSWORD"
        case .resetPassword(_):
            return "RESET_PASSWORD"
        case .confirmSignUp(_):
            return "CONFIRM_SIGN_UP"
        case .done:
            return "DONE"
        }
    }
}

extension AuthError {
    var errorCode: AmplifyErrorCode {
        switch self {
        /// Caused by issue in the way auth category is configured
        case .configuration(_, _, _):
            return underlyingError?.amplifyErrorCode ?? .configuration
            
        /// Caused by some error in the underlying service. Check the associated error for more details.
        case .service(_, _, _):
            return underlyingError?.amplifyErrorCode ?? .amazonService
            
        /// Caused by an unknown reason
        case .unknown(_, _):
            return underlyingError?.amplifyErrorCode ?? .unknown
            
        /// Caused when one of the input field is invalid
        case .validation(_, _, _, _):
            return underlyingError?.amplifyErrorCode ?? .validation
        
        /// Caused when the current session is not authorized to perform an operation
        case .notAuthorized(_, _, _):
            return underlyingError?.amplifyErrorCode ?? .notAuthorized
        
        /// Caused when a session is expired and needs the user to be re-authenticated
        case .sessionExpired(_, _, _):
            return underlyingError?.amplifyErrorCode ?? .sessionExpired
        
        /// Caused when an operation needs the user to be in signedIn state
        case .signedOut(_, _, _):
            return underlyingError?.amplifyErrorCode ?? .signedOut
        
        /// Caused when an operation is not valid with the current state of Auth category
        case .invalidState(_, _, _):
            return underlyingError?.amplifyErrorCode ?? .invalidState
        }
    }
}

extension APIError {
    var errorCode: AmplifyErrorCode {
        guard let error = self.underlyingError as? AuthError else { return .network }
        
        return error.errorCode
    }
}

extension Error {
    var amplifyErrorCode: AmplifyErrorCode? {
        if (self as NSError).domain == NSURLErrorDomain {
            return AmplifyErrorCode.network
        }
        
        guard let awsError = self as? AWSCognitoAuthError else { return nil }
        
        switch awsError {
        /// User not found in the system.
        case AWSCognitoAuthError.userNotFound:
            return AmplifyErrorCode.userNotFound
        
        /// User not confirmed in the system.
        case AWSCognitoAuthError.userNotConfirmed:
            return AmplifyErrorCode.userNotConfirm

        /// Username does not exists in the system.
        case AWSCognitoAuthError.usernameExists:
            return AmplifyErrorCode.usernameExist

        /// Alias already exists in the system.
        case AWSCognitoAuthError.aliasExists:
            return AmplifyErrorCode.aliasExists

        /// Error in delivering the confirmation code.
        case AWSCognitoAuthError.codeDelivery:
            return AmplifyErrorCode.codeDeliveryFailure

        /// Confirmation code entered is not correct.
        case AWSCognitoAuthError.codeMismatch:
            return AmplifyErrorCode.codeMismatch

        /// Confirmation code has expired.
        case AWSCognitoAuthError.codeExpired:
            return AmplifyErrorCode.expiredCode

        /// One or more parameters are incorrect.
        case AWSCognitoAuthError.invalidParameter:
            return AmplifyErrorCode.invalidParameter

        /// Password given is invalid.
        case AWSCognitoAuthError.invalidPassword:
            return AmplifyErrorCode.invalidPassword

        /// Number of allowed operation have exceeded.
        case AWSCognitoAuthError.limitExceeded:
            return AmplifyErrorCode.limitExceeded

        /// Amazon Cognito cannot find a multi-factor authentication (MFA) method.
        case AWSCognitoAuthError.mfaMethodNotFound:
            return AmplifyErrorCode.mfaMethodNotFound

        /// Software token TOTP multi-factor authentication (MFA) is not enabled for the user pool.
        case AWSCognitoAuthError.softwareTokenMFANotEnabled:
            return AmplifyErrorCode.softwareTokenMFANotEnabled

        /// Required to reset the password of the user.
        case AWSCognitoAuthError.passwordResetRequired:
            return AmplifyErrorCode.passwordResetRequired

        /// Amazon Cognito service cannot find the requested resource.
        case AWSCognitoAuthError.resourceNotFound:
            return AmplifyErrorCode.resourceNotFound

        /// The user has made too many failed attempts for a given action.
        case AWSCognitoAuthError.failedAttemptsLimitExceeded:
            return AmplifyErrorCode.tooManyFailedAttemps

        /// The user has made too many requests for a given operation.
        case AWSCognitoAuthError.requestLimitExceeded:
            return AmplifyErrorCode.limitExceeded

        /// Amazon Cognito service encounters an invalid AWS Lambda response or encounters an
        /// unexpected exception with the AWS Lambda service.
        case AWSCognitoAuthError.lambda:
            return AmplifyErrorCode.invalidLambdaResponse

        /// Device is not tracked.
        case AWSCognitoAuthError.deviceNotTracked:
            return AmplifyErrorCode.deviceNotTracked

        /// Error in loading the web UI.
        case AWSCognitoAuthError.errorLoadingUI:
            return AmplifyErrorCode.errorLoadingUI

        /// User cancelled the step
        case AWSCognitoAuthError.userCancelled:
            return AmplifyErrorCode.userCancelled
            
        /// Requested resource is not available with the current account setup.
        case AWSCognitoAuthError.invalidAccountTypeException:
            return AmplifyErrorCode.invalidAccountTypeException

        /// Request was not completed because of any network related issue
        case AWSCognitoAuthError.network:
            return AmplifyErrorCode.network
        }
    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}



