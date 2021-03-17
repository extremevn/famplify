# Flutter Amplify SDK
A Flutter SDK to use the [Amplify Library][df1]
With this SDK, your Flutter app can:
- Supports Cognito User Pools and User Identity based login
- Supports Federated Logins (Google, Facebook, Custom, etc.)
- Supports call Rest Api Aws

on Android and iOS platform

## Getting Started

Check out the example directory for a sample app using Flutter Amplify SDK.

##### **Android Integration**
To integrate your SDK into the Android part of your app, follow these steps:

1. Add an **awsconfiguration.json** file to **android/app/src/main/res/raw/awsconfiguration.json**
 **awsconfiguration.json** file's content will be look like
```sh
{
  "UserAgent": "aws-amplify-cli/0.1.0",
  "Version": "0.1.0",
  "IdentityManager": {
    "Default": {}
  },
  "CredentialsProvider": {
    "CognitoIdentity": {
      "Default": {
        "PoolId": "ap-southeast-1:xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx7179",
        "Region": "ap-southeast-1"
      }
    }
  },
  "CognitoUserPool": {
    "Default": {
      "PoolId": "ap-southeast-1_xxxXXXxx",
      "AppClientId": "xxxxxxXXxxxXXXx",
      "AppClientSecret": "xxxxxxxxxxxxxxxxxxxx",
      "Region": "ap-southeast-1"
    }
  },
  // Authen with Federated Logins (Google, Facebook, Custom, etc.) optional
  "Auth": {
    "Default": {
      "OAuth": {
        "WebDomain": "xxxx-xxx-xxxx.amazoncognito.com",
        "AppClientId": "xxxxxxxxx",
        "AppClientSecret": "xxxxxxxxxxxxxxxx",
        "SignInRedirectURI": "test://",
        "SignOutRedirectURI": "test://",
        "Scopes": [
          "phone",
          "email",
          "openid",
          "profile",
          "aws.cognito.signin.user.admin"
        ]
      },
      "authenticationFlowType": "USER_SRP_AUTH"
    }
  }
}
```
 2. Add an **amplifyconfiguration.json** file to **android/app/src/main/res/raw/amplifyconfiguration.json**
 **amplifyconfiguration.json** file's content will be look like
```sh
{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "SDKs": {
            "awsCognitoAuthSDK": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "ap-southeast-1:xxxx-xxx-xxx-xxxx",
                            "Region": "ap-southeast-1"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ap-southeast-1_xxxxxxxx",
                        "AppClientId": "xxxxxxxx",
                        "AppClientSecret": "xxxxxx",
                        "Region": "ap-southeast-1"
                    }
                },
                // Authen with Federated Logins (Google, Facebook, Custom, etc.) optional
                "Auth": {
                    "Default": {
                        "OAuth": {
                            "WebDomain": "xxxx-xxxx-xxxxx.amazoncognito.com",
                            "AppClientId": "xxxxxxxxx",
                            "AppClientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxx",
                            "SignInRedirectURI": "test://",
                            "SignOutRedirectURI": "test://",
                            "Scopes": [
                                "phone",
                                "email",
                                "openid",
                                "profile",
                                "aws.cognito.signin.user.admin"
                            ]
                        },
                        "authenticationFlowType": "USER_SRP_AUTH"
                    }
                }
            }
        }
    },
    // Config AWS Rest API
    "api": {
        "SDKs": {
            "awsAPISDK": {
                "xxxXXXXXxxx": {
                    "endpointType": "REST",
                    "endpoint": "https://xxxxxxxxxxxx.amazonaws.com/dev",
                    "region": "ap-southeast-1",
                    "authorizationType": "AMAZON_COGNITO_USER_POOLS"
                }
            }
        }
    }
}
```
3. Add dependencies in android module **android/build.gradle**
```sh
buildscript {
    ext.kotlin_version = '1.3.50'
    repositories {
        google()
        jcenter()
        mavenCentral() // Add this line
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:3.5.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-SDK:$kotlin_version"
        classpath 'com.amplifyframework:amplify-tools-gradle-SDK:1.0.1'  // Add this line
    }
}

allprojects {
    repositories {
        google()
        jcenter()
        mavenCentral() // Add this line
    }
}
```

4. Add dependency libs and compileOptions in android app **android/app/build.gradle**

```sh

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig signingConfigs.debug
        }
    }
    // Add this complile options
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'com.amplifyframework:core:1.0.0'   //Add this line
    implementation 'com.amplifyframework:aws-api:1.0.0'  //Add this line
    implementation 'com.amplifyframework:aws-auth-cognito:1.0.0'  //Add this line
}
```
5. (Optional) If you will login with google, facebook, custom, ... you need add fun onNewItent in **android/app/src/main/<pakage-name>/MainActivity** . Scheme need map with **amplifyconfiguration.json** and **awsconfiguration.json**

```sh
class MainActivity: FlutterActivity() {
    /// Add this fun
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.scheme != null && "test" == intent.scheme) {
            Amplify.Auth.handleWebUISignInResponse(intent)
        }
    }
}
```
 Add the following to **android/app/src/main/AndroidManifest.xml**
 ```sh
<manifest ...>
        <application ...>
            ...

            <!-- Add this section for AWS Cognito hosted UI-->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />

                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <data android:scheme="test" />
            </intent-filter>

        </application>
</manifest>
```
##### **IOS Integration**

Drag and Drop the same awsconfiguration.json file in the Runner folder under ios directory of your project.
Run Pod install
(Optional) If you will login with google, facebook, custom, ... you need change file ios/Info.plist like this

```sh
<plist version="1.0">

     <dict>
     <key>CFBundleURLTypes</key>
     <array>
         <dict>
             <key>CFBundleURLSchemes</key>
             <array>
                 <string>test</string>
             </array>
         </dict>
     </array>

     <!-- ... -->
     </dict>
```
##  **Usage**
#####  1. Import in your dart code
```sh
import 'package:xxxxxxxxxxxxxxxxx/xxxxx.dart'
```
#####  2.Initialization
```sh
 @override
  void initState() {
    FlutterAmplifySdk.initialize().then((String statusAmplify) {
      debugPrint(statusAmplify);
    }).catchError((error) {
      debugPrint(error.toString());
    });
    super.initState();
  }
```

##### 3.Working with Authentication
 3.1 Signup
 ```sh
 final Map<String, String> data = <String, String>{};
 data['email'] = 'test@gmail.com';
 data['phone'] = '+84XXXXXXXXXXX';
 data['nickname'] = 'nickname';
 FlutterAmplifySdk.signUp("userName", "password", data).then((tracked) {
                debugPrint(tracked.isSignUpComplete.toString());
                }).catchError((error) {
                 debugPrint(error.toString());
                });
 ```

  3.2 Confirm Signup
 ```sh
 FlutterAmplifySdk.confirmSignUp("userName", "confirmCode").then((tracked) {
                        debugPrint(tracked.isSignUpComplete.toString());
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
   3.3 SignIn
 ```sh
 FlutterAmplifySdk.signIn("userName", "password").then((tracked) {
                        debugPrint("sign in success");
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
 3.4 Authen with social network
 ```sh
 FlutterAmplifySdk.authenWithSocialNetwork("google").then((dataRes) {
                        debugPrint("authen google res =========> $dataRes");
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
  3.5 Resend signUp code
 ```sh
FlutterAmplifySdk.resendSignUpCode("userName").then((signUpResult) {
                    debugPrint(
                        "Resend signUp code: ${signUpResult.isSignUpComplete}");
                  }).catchError((error) {
                    debugPrint(error.toString());
                  });
 ```
   3.6 Reset password
 ```sh
FlutterAmplifySdk.resetPassword("userName").then((resetPassResult) {
                    debugPrint( 'Reset pass: ${resetPassResult.isPasswordReset}');
                  }).catchError((error) {
                    debugPrint(error.toString());
                  });
 ```
 3.7 Confirm Reset Password
 ```sh
FlutterAmplifySdk.confirmResetPassword("userName", "newPassword", "confirmRestPassCode")
                          .then((confirmResetPassResult) {
                        debugPrint('Confirm Reset pass: $confirmResetPassResult');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
  3.8 Change Password
 ```sh
FlutterAmplifySdk.changePassword("passCurrent", "passNew").then((changePassResult) {
                        debugPrint('Change pass: $changePassResult');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
 3.9 Sign Out
 ```sh
FlutterAmplifySdk.signOut().then((result) {
                    debugPrint('Sign out success');
                  }).catchError((error) {
                    debugPrint(error.toString());
                  });
 ```
  3.10 Sign Out Globally
 ```sh
FlutterAmplifySdk.signOutGlobally().then((result) {
                    debugPrint('Sign out globally success');
                  }).catchError((error) {
                    debugPrint(error.toString());
                  });
 ```
   3.11 Get token
 ```sh
FlutterAmplifySdk.getTokens().then((tokens) {
                        debugPrint('idToken: ${tokens.idToken}');
                        debugPrint('accessToken: ${tokens.accessToken}');
                        debugPrint('refreshToken: ${tokens.refreshToken}');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
 3.12 Get credentials
 ```sh
FlutterAmplifySdk.getCredentials().then((credential) {
                        debugPrint('accessKeyId: ${credential.accessKeyId}');
                        debugPrint('secretKey: ${credential.secretKey}');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
 3.13 Get Identity Id
 ```sh
FlutterAmplifySdk.getIdentityId().then((identityIdRes) {
                        debugPrint('identityId: $identityIdRes');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
 3.14 Check user signined
 ```sh
FlutterAmplifySdk.isSignedIn().then((isSigned) {
                       debugPrint(isSigned ? "Signed" : "Not Signed");
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```
 3.15 Get user name
 ```sh
FlutterAmplifySdk.getUsername().then((userNameRes) {
                       debugPrint('User name: $userNameRes');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```

 #####  4.Working with Api

4.1 Call Post Api
 ```sh
                    final bodyPost = <String, dynamic>{};
                    bodyPost["userId"] = "1069";
                    bodyPost["name"] = "nameUser";
                    bodyPost["age"] = 30;
                    FlutterAmplifySdk.postDataApi("idToken", "/users", bodyPost).then((dataRes) {
                        debugPrint('Data response: $dataRes');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```

 4.2 Call Get Api
 ```sh
                    final bodyGet = <String, dynamic>{};
                    FlutterAmplifySdk.getDataApi("idToken", "/users/1069", bodyGet) .then((dataRes) {
                       debugPrint('Data response: $dataRes');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```

 4.3 Call Delete Api
 ```sh
                    final bodyDelete = <String, dynamic>{};
                    FlutterAmplifySdk.deleteDataApi("idToken", "/users/1069", bodyDelete).then((dataRes) {
                        debugPrint('Data response: $dataRes');
                      }).catchError((error) {
                        debugPrint(error.toString());
                      });
 ```

## Issues and feedback
Please file Flutter Amplify SDK specific issues, bugs, or feature requests in our [issue tracker][df2]

SDK issues that are not specific to Flutter Amplify SDK can be filed in the Flutter [issue tracker][df2]

## Dart Versions

- Dart 2: >= 2.6.0

## Contributor

- [Justin Lewis](https://github.com/justin-lewis) (Maintainer)
- [bigzero1000](https://github.com/bigzero1000) (Maintainer)
  
## License
[MIT](https://gitlab.extremevn.vn/development-mobile-1/library/flutter_amplify_sdk/raw/master/LICENSE)


[df1]: <https://docs.amplify.aws/>
[df2]: https://gitlab.extremevn.vn/development-mobile-1/library/flutter_amplify_sdk/issues>