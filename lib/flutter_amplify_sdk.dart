/// MIT License
/// Copyright (c) [2020] Extreme Viet Nam
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import 'dart:async';
import 'package:flutter/services.dart';
import 'src/vn/com/extremevn/flutter_amplify_sdk/auth_reset_password/auth_reset_password_result.dart';
import 'src/vn/com/extremevn/flutter_amplify_sdk/aws_credential/aws_credential.dart';
import 'src/vn/com/extremevn/flutter_amplify_sdk/common/auth_code_delivery_detail.dart';
import 'src/vn/com/extremevn/flutter_amplify_sdk/common/common.dart';
import 'src/vn/com/extremevn/flutter_amplify_sdk/exception/exception.dart';
import 'src/vn/com/extremevn/flutter_amplify_sdk/sign_in/sign_in_result.dart';
import 'src/vn/com/extremevn/flutter_amplify_sdk/sign_up/signup_result.dart';
import 'src/vn/com/extremevn/flutter_amplify_sdk/token/tokens.dart';

export 'src/vn/com/extremevn/flutter_amplify_sdk/exception/exception.dart';

enum SocialNetwork { apple, google }

// ignore: avoid_classes_with_only_static_members
class FlutterAmplifySdk {
  static const MethodChannel _methodChannel =
      MethodChannel('flutter_amplify_sdk');

  static Future<String> get platformVersion async {
    final version = await _methodChannel.invokeMethod('getPlatformVersion');
    return version as String;
  }

  /// Initialize amplify sdk
  static Future<String> initialize() async {
    try {
      return await _methodChannel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      return Future.error(e);
    }
  }

  /// Sign up request from user's [username], [password] and [userAttributes].
  /// Response is a [AuthSignUpResult] object containing the isSignUpComplete [bool]
  static Future<AuthSignUpResult> signUp(String username, String password,
      Map<String, String> userAttributes) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['username'] = username;
      arguments['password'] = password;
      arguments['userAttributes'] = userAttributes;
      final signUpResult =
          await _methodChannel.invokeMethod('signUp', arguments);
      return AuthSignUpResult(
          signUpResult['destination']?.toString() ?? '',
          signUpResult['attributeName']?.toString() ?? '',
          signUpResult['deliveryValue']?.toString() ?? '',
          isSignUpComplete: signUpResult['isSignUpComplete'] is bool);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Confirms a multi factor sign up request from user's [username] and confirmation [code].
  /// Response is a [AuthSignUpResult] object containing the isSignUpComplete [bool]
  static Future<AuthSignUpResult> confirmSignUp(
      String username, String code) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['username'] = username;
      arguments['code'] = code;
      final signUpResult =
          await _methodChannel.invokeMethod('confirmSignUp', arguments);
      return AuthSignUpResult(
          signUpResult['destination']?.toString() ?? '',
          signUpResult['attributeName']?.toString() ?? '',
          signUpResult['deliveryValue']?.toString() ?? '',
          isSignUpComplete: signUpResult['isSignUpComplete'] is bool);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Signs in the user in the Cognito User Pool.
  ///
  /// Response is a [SignInResult] object containing the [SignInState], user attributes [Map<String, String>]
  /// and [UserCodeDeliveryDetails],
  static Future<AuthSignInResult> signIn(
      String username, String password) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['username'] = username;
      arguments['password'] = password;
      final signInResult =
          await _methodChannel.invokeMethod('signIn', arguments);
      var additionalInfo = <String, String>{};
      final additionalInfoRes =
          (signInResult['additionalInfo'] ?? <String, String>{}) as Map;
      if (additionalInfoRes.isNotEmpty) {
        additionalInfo = additionalInfoRes.cast<String, String>();
      }
      return AuthSignInResult(
          AuthNextSignInStep(
              parseAuthSignInStep(signInResult['authSignInStep'].toString()),
              additionalInfo,
              AuthCodeDeliveryDetails(
                  signInResult['destination']?.toString() ?? '',
                  signInResult['deliveryMedium']?.toString() ?? '',
                  signInResult['attributeName']?.toString() ?? '')),
          isSignInComplete: signInResult['isSignInComplete'] is bool);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Re-sends a confirmation code for confirming user sign up in case of no/delayed confirmation code
  /// delivery via SMS/email.
  static Future<AuthSignUpResult> resendSignUpCode(String username) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['username'] = username;
      final signUpResult =
          await _methodChannel.invokeMethod('resendSignUpCode', arguments);
      return AuthSignUpResult(
          signUpResult['destination']?.toString() ?? '',
          signUpResult['attributeName']?.toString() ?? '',
          signUpResult['deliveryValue']?.toString() ?? '',
          isSignUpComplete: signUpResult['isSignUpComplete'] is bool);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Sends a confirmation code for resetting user's password using his/her [username].
  static Future<AuthResetPasswordResult> resetPassword(String username) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['username'] = username;
      final resetPassResult =
          await _methodChannel.invokeMethod('resetPassword', arguments);

      var additionalInfo = <String, String>{};
      final additionalInfoRes =
          (resetPassResult['additionalInfo'] ?? <String, String>{}) as Map;
      if (additionalInfoRes.isNotEmpty) {
        additionalInfo = additionalInfoRes.cast<String, String>();
      }
      return AuthResetPasswordResult(
          AuthNextResetPasswordStep(
              parseAuthResetPasswordStep(
                  resetPassResult['resetPasswordStep'].toString()),
              additionalInfo,
              AuthCodeDeliveryDetails(
                  resetPassResult['destination']?.toString() ?? '',
                  resetPassResult['deliveryMedium']?.toString() ?? '',
                  resetPassResult['attributeName']?.toString() ?? '')),
          isPasswordReset: resetPassResult['isPasswordReset'] is bool);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Sets a new password using the [confirmationCode] and [newPassword] typed by the user.
  static Future<bool> confirmResetPassword(
      String userName, String newPassword, String confirmationCode) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['username'] = userName;
      arguments['newPassword'] = newPassword;
      arguments['confirmationCode'] = confirmationCode;
      return await _methodChannel.invokeMethod(
          'confirmResetPassword', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Change pass word using [oldPassword] and [newPassword] typed by the user.
  static Future<bool> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['oldPassword'] = oldPassword;
      arguments['newPassword'] = newPassword;
      return await _methodChannel.invokeMethod('changePassword', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Signs out the user from the current application.
  static Future<void> signOut() async {
    try {
      await _methodChannel.invokeMethod('signOut');
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Signs out the user globally from all the applications.
  static Future<bool> signOutGlobally() async {
    try {
      return await _methodChannel.invokeMethod('signOutGlobally');
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Retrieves the [Tokens] for the currently signed in user.
  static Future<Tokens> getTokens() async {
    try {
      final tokens = await _methodChannel.invokeMethod('getTokens');
      return Tokens(
          tokens['accessToken']?.toString() ?? '',
          tokens['idToken']?.toString() ?? '',
          tokens['refreshToken']?.toString() ?? '');
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Retrieves the [AWSCredentials] for the currently signed in user.
  ///
  /// These credentials can be used to access other AWS services or can be
  /// exchanged for necessary certificates/credentials to use the other AWS services.
  static Future<AWSCredentials> getCredentials() async {
    try {
      final credentials = await _methodChannel.invokeMethod('getCredentials');
      return AWSCredentials(credentials['accessKeyId']?.toString() ?? '',
          credentials['secretKey']?.toString() ?? '');
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Retrieves the [identityId] for the current signed in user.
  static Future<String> getIdentityId() async {
    try {
      return await _methodChannel.invokeMethod('getIdentityId');
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Checks and returns true if the user is signed in.
  static Future<bool> isSignedIn() async {
    try {
      return await _methodChannel.invokeMethod('isSignedIn');
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Retrieves the [username] for the current signed in user.
  static Future<String> getUsername() async {
    try {
      return await _methodChannel.invokeMethod('getUsername');
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Call post api aws using [apiName],[path], [body] and optional [token].
  /// Return api respond whose data is json format [String]
  static Future<String> postDataApi(
      String apiName, String path, Map<String, dynamic> body,
      {String token = ''}) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['apiName'] = apiName;
      arguments['tokenUser'] = token;
      arguments['path'] = path;
      arguments['body'] = body;
      return await _methodChannel.invokeMethod('postApi', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Call post put aws using [apiName],[path], [body] and optional [token].
  /// Return api respond whose data is json format [String]
  static Future<String> putDataApi(
      String apiName, String path, Map<String, dynamic> body,
      {String token = ''}) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['apiName'] = apiName;
      arguments['tokenUser'] = token;
      arguments['path'] = path;
      arguments['body'] = body;
      return await _methodChannel.invokeMethod('putApi', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Call get api aws using [apiName],[path], [body] and optional [token].
  /// Return api respond whose data is json format [String]
  static Future<String> getDataApi(
      String apiName, String path, Map<String, dynamic> body,
      {String token = ''}) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['apiName'] = apiName;
      arguments['tokenUser'] = token;
      arguments['path'] = path;
      arguments['body'] = body;
      return await _methodChannel.invokeMethod('getApi', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Call delete api aws using [apiName],[path], [body] and optional [token].
  /// Return api respond whose data is json format [String]
  static Future<String> deleteDataApi(
      String apiName, String path, Map<String, dynamic> body,
      {String token = ''}) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['apiName'] = apiName;
      arguments['tokenUser'] = token;
      arguments['path'] = path;
      arguments['body'] = body;
      return await _methodChannel.invokeMethod('deleteApi', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Authentication user using web with  [SocialNetwork].
  /// Respond status authenticate of user [bool]
  static Future<bool> authenWithSocialNetwork(SocialNetwork type) async {
    try {
      final arguments = <String, dynamic>{};
      if (type == SocialNetwork.apple) {
        arguments['type'] = 'apple';
      } else if (type == SocialNetwork.google) {
        arguments['type'] = 'google';
      }
      return await _methodChannel.invokeMethod(
          'authenWithSocialNetwork', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Update user phone [userPhone] of User Cognito.
  /// Response true is success. Other is failure
  static Future<bool> updateUserPhone(String userPhone) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['userPhone'] = userPhone;
      return await _methodChannel.invokeMethod('updateUserPhone', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Confirm update  userPhone of User Cognito using [confirmCode]
  /// Response true is success. Other is failure
  static Future<bool> confirmUpdateUserPhone(String confirmCode) async {
    try {
      final arguments = <String, dynamic>{};
      arguments['confirmCode'] = confirmCode;
      return await _methodChannel.invokeMethod(
          'confirmUpdateUserPhone', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Resend confirmCode when update user phone of user Cognito
  /// Return true is success. Other is failure
  static Future<bool> resendConfirmCodeUpdateUserPhone() async {
    try {
      final arguments = <String, dynamic>{};
      return await _methodChannel.invokeMethod(
          'resendConfirmCodeUpdateUserPhone', arguments);
    } on PlatformException catch (e) {
      return Future.error(transformPlatformException(e));
    }
  }

  /// Transform [PlatformException] to [AmplifySdkException]
  static AmplifySdkException transformPlatformException(
          PlatformException platformException) =>
      AmplifySdkException(platformException.code, platformException.message);
}
