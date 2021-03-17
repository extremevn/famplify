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

import 'package:flutter_amplify_sdk/src/vn/com/extremevn/flutter_amplify_sdk/sign_in/sign_in_result.dart';
import 'package:flutter_amplify_sdk/src/vn/com/extremevn/flutter_amplify_sdk/auth_reset_password/auth_reset_password_result.dart';

AuthSignInStep parseAuthSignInStep(String authSignInStep) {
  switch (authSignInStep) {
    case "CONFIRM_SIGN_IN_WITH_SMS_MFA_CODE":
      return AuthSignInStep.confirmSignInWithSmsMfaCode;
    case "CONFIRM_SIGN_IN_WITH_CUSTOM_CHALLENGE":
      return AuthSignInStep.confirmSignInWithCustomChallenge;
    case "CONFIRM_SIGN_IN_WITH_NEW_PASSWORD":
      return AuthSignInStep.confirmSignInWithNewPassword;
    case "RESET_PASSWORD":
      return AuthSignInStep.resetPassword;
    case "CONFIRM_SIGN_UP":
      return AuthSignInStep.confirmSignUp;
    case "NEW_PASSWORD_REQUIRED":
      return AuthSignInStep.done;
    default:
      return AuthSignInStep.done;
  }
}

AuthResetPasswordStep parseAuthResetPasswordStep(String authResetPasswordStep) {
  switch (authResetPasswordStep) {
    case "CONFIRM_RESET_PASSWORD_WITH_CODE":
      return AuthResetPasswordStep.confirmResetPasswordWithCode;
    default:
      return AuthResetPasswordStep.done;
  }
}

