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

import Flutter
import UIKit
import Amplify

enum ApiMethod {
    case get
    case post
    case delete
    case put
}

public class SwiftFlutterAmplifySdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_amplify_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAmplifySdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        switch call.method {
            
        case "initialize":
            SwiftFlutterAmplifySDK.initialize(result: result)
            
        case "signUp":
            guard
                let username = arguments["username"] as? String,
                let password = arguments["password"] as? String,
                let userAttributes = arguments["userAttributes"] as? [String: String] else {
                    return
            }
            SwiftFlutterAmplifySDK.signUp(result: result, username: username, password: password, userAttributes: userAttributes)
            
        case "confirmSignUp":
            guard
                let username = arguments["username"] as? String,
                let confirmationCode = arguments["code"] as? String else {
                    return
            }
            
            SwiftFlutterAmplifySDK.confirmSignUp(result: result, username: username, confirmationCode: confirmationCode)
            
        case "signIn":
            guard
                let username = arguments["username"] as? String,
                let password = arguments["password"] as? String else {
                    return
            }
            SwiftFlutterAmplifySDK.signIn(result: result, username: username, password: password)
        
        case "resendSignUpCode":
            guard let username = arguments["username"] as? String else {
                return
            }
            SwiftFlutterAmplifySDK.resendSignUpCode(result: result, username: username)
        
        case "resetPassword":
            guard let username = arguments["username"] as? String else {
                return
            }
            SwiftFlutterAmplifySDK.resetPassword(result: result, username: username)
        
        case "confirmResetPassword":
            guard
                let username = arguments["username"] as? String,
                let newPassword = arguments["newPassword"] as? String,
                let confirmationCode = arguments["confirmationCode"] as? String else {
                    return
            }
            SwiftFlutterAmplifySDK.confirmResetPassword(result: result, username: username, newPassword: newPassword, confirmationCode: confirmationCode)
        
        case "changePassword":
            guard
                let oldPassword = arguments["oldPassword"] as? String,
                let newPassword = arguments["newPassword"] as? String else {
                    return
            }
            SwiftFlutterAmplifySDK.changePassword(result: result, oldPassword: oldPassword, newPassword: newPassword)
            
        case "signOut":
            SwiftFlutterAmplifySDK.signOut(result: result)
        
        case "signOutGlobally":
            SwiftFlutterAmplifySDK.globalSignOut(result: result)
        
        case "getTokens":
            SwiftFlutterAmplifySDK.getTokens(result: result)
            
        case "getCredentials":
            SwiftFlutterAmplifySDK.getCredentials(result: result)
            
        case "getIdentityId":
            SwiftFlutterAmplifySDK.getIdentityId(result: result)
        
        case "isSignedIn":
            SwiftFlutterAmplifySDK.isSignedIn(result: result)
            
        case "getUsername":
            SwiftFlutterAmplifySDK.getUsername(result: result)
        
        case "authenWithSocialNetwork":
            guard let type = arguments["type"] as? String else { return }
            
            var authorProvider: AuthProvider
            if type == "google" {
                authorProvider = .google
            } else {
                authorProvider = .apple
            }
            SwiftFlutterAmplifySDK.authenWithSocialNetwork(result: result, authorProvider: authorProvider)
            
        case "updateUserPhone":
            guard let phone = arguments["userPhone"] as? String else { return }
            SwiftFlutterAmplifySDK.updatePhone(phone, result: result)
            
        case "confirmUpdateUserPhone":
            guard let code = arguments["confirmCode"] as? String else { return }
            SwiftFlutterAmplifySDK.confirmPhone(code: code, result: result)
            
        case "resendConfirmCodeUpdateUserPhone":
            SwiftFlutterAmplifySDK.resendConfirmPhoneCode(result: result)
            
        case "getApi":
            guard
                let path = arguments["path"] as? String,
                let apiName = arguments["apiName"] as? String,
                let token = arguments["tokenUser"] as? String else {
                    return
            }
            
            SwiftFlutterAmplifySDK.requestAPI(name: apiName, path: path, method: .get, token: token, params: nil, result: result)
            
        case "postApi":
            guard
                let path = arguments["path"] as? String,
                let apiName = arguments["apiName"] as? String,
                let token = arguments["tokenUser"] as? String else {
                    return
            }
            
            let params = arguments["body"] as? [String: Any]
            
            SwiftFlutterAmplifySDK.requestAPI(name: apiName, path: path, method: .post, token: token, params: params, result: result)
            
        case "deleteApi":
                   guard
                    let path = arguments["path"] as? String,
                    let apiName = arguments["apiName"] as? String,
                    let token = arguments["tokenUser"] as? String else {
                        return
                   }
                   
                   let params = arguments["body"] as? [String: Any]
                   
            SwiftFlutterAmplifySDK.requestAPI(name: apiName, path: path, method: .delete, token: token, params: params, result: result)
            
        case "putApi":
                   guard
                    let path = arguments["path"] as? String,
                    let apiName = arguments["apiName"] as? String,
                    let token = arguments["tokenUser"] as? String else {
                        return
                   }
                   
                   let params = arguments["body"] as? [String: Any]
                   
            SwiftFlutterAmplifySDK.requestAPI(name: apiName, path: path, method: .put, token: token, params: params, result: result)
        default:
            break
        }
    }
}

