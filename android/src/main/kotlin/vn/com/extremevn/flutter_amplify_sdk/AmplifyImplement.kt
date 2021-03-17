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

package vn.com.extremevn.flutter_amplify_sdk

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.amazonaws.services.cognitoidentityprovider.model.*
import com.amplifyframework.AmplifyException
import com.amplifyframework.api.ApiException
import com.amplifyframework.api.aws.AWSApiPlugin
import com.amplifyframework.api.rest.RestOptions
import com.amplifyframework.api.rest.RestResponse
import com.amplifyframework.auth.AuthException
import com.amplifyframework.auth.AuthProvider
import com.amplifyframework.auth.AuthUserAttribute
import com.amplifyframework.auth.AuthUserAttributeKey
import com.amplifyframework.auth.cognito.AWSCognitoAuthPlugin
import com.amplifyframework.auth.cognito.AWSCognitoAuthSession
import com.amplifyframework.auth.options.AuthSignOutOptions
import com.amplifyframework.auth.options.AuthSignUpOptions
import com.amplifyframework.auth.result.AuthSessionResult
import com.amplifyframework.auth.result.step.AuthResetPasswordStep
import com.amplifyframework.auth.result.step.AuthSignInStep
import com.amplifyframework.core.Amplify
import com.amplifyframework.core.Consumer
import com.google.gson.Gson
import com.amplifyframework.api.rest.RestOptions.Builder
import io.flutter.plugin.common.MethodChannel

enum class MethodCallApi(val tag: String) {
    POST("Api:Post"),
    GET("Api:Get"),
    PUT("Api:Put"),
    DELETE("Api:Delete")
}

class AmplifyImplement {
    companion object {
        //region Tag
        private const val TAG_AUTH_SIGN_UP = "Auth:SignUp"
        private const val TAG_AUTH_SIGN_IN = "Auth:SignIn"
        private const val TAG_AUTH_MANAGER = "Auth:Manager"
        private const val TAG_ERROR = "Error"
        //endregion

        //region Error code
        private const val ERROR_CODE_RESOURCE_NOT_FOUND_EXCEPTION = "ResourceNotFoundException"
        private const val ERROR_CODE_INVALID_PARAMETER_EXCEPTION = "InvalidParameterException"
        private const val ERROR_CODE_UNEXPECTED_LAMBDA_EXCEPTION = "UnexpectedLambdaException"
        private const val ERROR_CODE_USER_LAMBDA_VALIDATION_EXCEPTION = "UserLambdaValidationException"
        private const val ERROR_CODE_NOT_AUTHORIZED_EXCEPTION = "NotAuthorizedException"
        private const val ERROR_CODE_INVALID_PASSWORD_EXCEPTION = "InvalidPasswordException"
        private const val ERROR_CODE_USERNAME_EXISTS_EXCEPTION = "UsernameExistsException"
        private const val ERROR_CODE_CODE_DELIVERY_FAILURE_EXCEPTION = "CodeDeliveryFailureException"
        private const val ERROR_CODE_TOO_MANY_FAILED_ATTEMPTS_EXCEPTION = "TooManyFailedAttemptsException"
        private const val ERROR_CODE_CODE_MISMATCH_EXCEPTION = "CodeMismatchException"
        private const val ERROR_CODE_EXPIRED_CODE_EXCEPTION = "ExpiredCodeException"
        private const val ERROR_CODE_INVALID_LAMBDA_RESPONSE_EXCEPTION = "InvalidLambdaResponseException"
        private const val ERROR_CODE_ALIAS_EXISTS_EXCEPTION = "AliasExistsException"
        private const val ERROR_CODE_TOO_MANY_REQUESTS_EXCEPTION = "TooManyRequestsException"
        private const val ERROR_CODE_LIMIT_EXCEEDED_EXCEPTION = "LimitExceededException"
        private const val ERROR_CODE_USER_NOT_FOUND_EXCEPTION = "UserNotFoundException"
        private const val ERROR_CODE_INTERNAL_ERROR_EXCEPTION = "InternalErrorException"
        private const val ERROR_CODE_DEFAULT = "DefaultException"
        private const val ERROR_CODE_API = "ApiException"
        private const val ERROR_CODE_UNKNOWN = "UnknownException"
        //endregion

        private const val MESSAGE_USER_TOKEN_INVALID = "Your session has expired.Please sign in and reattempt the operation"
        private val handler = Handler(Looper.getMainLooper())

        fun initialize(context: Context, result: MethodChannel.Result) {

            try {
                Amplify.addPlugin(AWSCognitoAuthPlugin())
                Amplify.addPlugin(AWSApiPlugin())
                Amplify.configure(context)
                handler.post {
                    result.success("Initialized Amplify Success")
                }
                Log.d("Amplify:Init", "Initialized Amplify Success")
            } catch (error: AmplifyException) {
                Log.e("Amplify:Init", "Could not initialize Amplify", error)
                handler.post {
                    result.error(ERROR_CODE_DEFAULT, "Could not initialize Amplify", error.message)
                }
            }
        }

        fun signUp(result: MethodChannel.Result, username: String, password: String, userAttributes: Map<String, String>) {

            val attributes: ArrayList<AuthUserAttribute> = ArrayList()
            userAttributes.forEach {
                when (it.key) {
                    "email" -> attributes.add(AuthUserAttribute(AuthUserAttributeKey.email(), it.value))
                    "phone" -> attributes.add(AuthUserAttribute(AuthUserAttributeKey.phoneNumber(), it.value))
                    "name" -> attributes.add(AuthUserAttribute(AuthUserAttributeKey.name(), it.value))
                    "gender" -> attributes.add(AuthUserAttribute(AuthUserAttributeKey.gender(), it.value))
                    else -> Log.d(TAG_AUTH_SIGN_UP, "Key: ${it.key} not support attributes")
                }
            }

            Amplify.Auth.signUp(username, password, AuthSignUpOptions.builder().userAttributes(attributes).build(),
                    { resultSignUp ->
                        Log.d(TAG_AUTH_SIGN_UP, "Result signUp: $resultSignUp")
                        handler.post {
                            result.success(hashMapOf(
                                    "isSignUpComplete" to resultSignUp.isSignUpComplete,
                                    "destination" to resultSignUp.nextStep.codeDeliveryDetails?.destination,
                                    "attributeName" to resultSignUp.nextStep.codeDeliveryDetails?.attributeName,
                                    "deliveryValue" to resultSignUp.nextStep.codeDeliveryDetails?.deliveryMedium?.value
                            ))
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_SIGN_UP)
                    }
            )
        }

        fun confirmSignUp(result: MethodChannel.Result, username: String, code: String) {

            Amplify.Auth.confirmSignUp(username, code,
                    { resultConfirmSignUp ->
                        Log.d(TAG_AUTH_SIGN_UP, if (resultConfirmSignUp.isSignUpComplete) "Confirm signUp succeeded" else "Confirm sign up not complete")
                        handler.post {
                            result.success(hashMapOf(
                                    "isSignUpComplete" to resultConfirmSignUp.isSignUpComplete,
                                    "destination" to resultConfirmSignUp.nextStep.codeDeliveryDetails?.destination,
                                    "attributeName" to resultConfirmSignUp.nextStep.codeDeliveryDetails?.attributeName,
                                    "deliveryValue" to resultConfirmSignUp.nextStep.codeDeliveryDetails?.deliveryMedium?.value
                            ))
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_SIGN_UP)
                    }
            )

        }

        fun signIn(result: MethodChannel.Result, username: String, password: String) {
            Amplify.Auth.signIn(username, password,
                    { resultSignIn ->
                        Log.d(TAG_AUTH_SIGN_IN, if (resultSignIn.isSignInComplete) "Sign in succeeded: $resultSignIn" else "Sign in not complete")
                        handler.post {
                            result.success(hashMapOf(
                                    "isSignInComplete" to resultSignIn.isSignInComplete,
                                    "authSignInStep" to convertAuthSignInStep(resultSignIn.nextStep.signInStep),
                                    "additionalInfo" to resultSignIn.nextStep.additionalInfo,
                                    "destination" to resultSignIn.nextStep.codeDeliveryDetails?.destination,
                                    "deliveryMedium" to resultSignIn.nextStep.codeDeliveryDetails?.deliveryMedium?.value,
                                    "attributeName" to resultSignIn.nextStep.codeDeliveryDetails?.attributeName
                            ))
                        }

                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_SIGN_IN)
                    }
            )
        }

        fun resendSignUpCode(result: MethodChannel.Result, username: String) {

            Amplify.Auth.resendSignUpCode(username,
                    { resultResendSignUp ->
                        Log.d(TAG_AUTH_SIGN_UP, if (resultResendSignUp.isSignUpComplete) "Resend signUp code succeeded" else "Resend signUp code not complete")
                        handler.post {
                            result.success(hashMapOf(
                                    "isSignUpComplete" to resultResendSignUp.isSignUpComplete,
                                    "destination" to resultResendSignUp.nextStep.codeDeliveryDetails?.destination,
                                    "attributeName" to resultResendSignUp.nextStep.codeDeliveryDetails?.attributeName,
                                    "deliveryValue" to resultResendSignUp.nextStep.codeDeliveryDetails?.deliveryMedium?.value
                            ))
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_SIGN_UP)
                    })
        }

        fun resetPassword(result: MethodChannel.Result, username: String) {

            Amplify.Auth.resetPassword(username,
                    { resultResetPass ->
                        Log.d(TAG_AUTH_MANAGER, "Reset pass succeeded")
                        handler.post {
                            result.success(hashMapOf(
                                    "isPasswordReset" to resultResetPass.isPasswordReset,
                                    "resetPasswordStep" to convertAuthResetPasswordStep(resultResetPass.nextStep.resetPasswordStep),
                                    "additionalInfo" to resultResetPass.nextStep.additionalInfo,
                                    "destination" to resultResetPass.nextStep.codeDeliveryDetails?.destination,
                                    "deliveryMedium" to resultResetPass.nextStep.codeDeliveryDetails?.deliveryMedium?.value,
                                    "attributeName" to resultResetPass.nextStep.codeDeliveryDetails?.attributeName
                            ))
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    })

        }

        fun confirmResetPassword(result: MethodChannel.Result, newPassword: String, confirmationCode: String) {

            Amplify.Auth.confirmResetPassword(newPassword, confirmationCode,
                    {
                        Log.d(TAG_AUTH_MANAGER, "Reset pass succeeded")
                        handler.post {
                            result.success(true)
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    })


        }

        fun changePassword(result: MethodChannel.Result, oldPassword: String, newPassword: String) {

            Amplify.Auth.updatePassword(oldPassword, newPassword,
                    {
                        Log.d(TAG_AUTH_MANAGER, "Change pass succeeded")
                        handler.post {
                            result.success(true)
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    })


        }

        fun signOut(result: MethodChannel.Result) {
            Amplify.Auth.signOut(
                    {
                        Log.d(TAG_AUTH_MANAGER, "Signed out successfully")
                        handler.post {
                            result.success(true)
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    }
            )
        }

        fun signOutGlobally(result: MethodChannel.Result) {

            Amplify.Auth.signOut(
                    AuthSignOutOptions.builder().globalSignOut(true).build(),
                    {
                        Log.i(TAG_AUTH_MANAGER, "Signed out globally success")
                        handler.post {
                            result.success(true)
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    }
            )
        }

        fun getTokens(result: MethodChannel.Result) {

            Amplify.Auth.fetchAuthSession(
                    { resultAuth ->
                        val awsAuthSession = resultAuth as AWSCognitoAuthSession
                        Log.d(TAG_AUTH_MANAGER, awsAuthSession.toString())
                        val userPoolTokens = awsAuthSession.userPoolTokens.value
                        // Check user Delete
                        if (userPoolTokens == null) {
                            Log.e(TAG_AUTH_MANAGER, MESSAGE_USER_TOKEN_INVALID)
                            handler.post {
                                result.error(ERROR_CODE_UNKNOWN, MESSAGE_USER_TOKEN_INVALID, "")
                            }
                        } else {
                            handler.post {
                                result.success(hashMapOf(
                                        "accessToken" to userPoolTokens.accessToken,
                                        "idToken" to userPoolTokens.idToken,
                                        "refreshToken" to userPoolTokens.refreshToken))
                            }
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    }
            )
        }

        fun getCredentials(result: MethodChannel.Result) {
            Amplify.Auth.fetchAuthSession(
                    { resultAuth ->
                        val awsAuthSession = resultAuth as AWSCognitoAuthSession
                        Log.d(TAG_AUTH_MANAGER, awsAuthSession.toString())
                        handler.post {
                            result.success(hashMapOf(
                                    "accessKeyId" to awsAuthSession.awsCredentials.value?.awsAccessKeyId,
                                    "secretKey" to awsAuthSession.awsCredentials.value?.awsSecretKey))
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    }
            )
        }

        fun getIdentityId(result: MethodChannel.Result) {

            Amplify.Auth.fetchAuthSession(
                    { resultAuth ->
                        val awsAuthSession = resultAuth as AWSCognitoAuthSession
                        when (awsAuthSession.identityId.type) {
                            AuthSessionResult.Type.SUCCESS -> {
                                Log.d(TAG_AUTH_MANAGER, "IdentityId: " + awsAuthSession.identityId.value)
                                handler.post {
                                    result.success(awsAuthSession.identityId.value)
                                }
                            }

                            AuthSessionResult.Type.FAILURE -> {
                                Log.d(TAG_AUTH_MANAGER, "IdentityId not present because: " + awsAuthSession.identityId.error.toString())
                                handler.post {
                                    result.error(TAG_ERROR, "Error getting identityId", awsAuthSession.identityId.error.toString())
                                }
                            }
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    }
            )
        }

        fun isSignedIn(result: MethodChannel.Result) {
            Amplify.Auth.fetchAuthSession(
                    { resultAuth ->
                        val awsAuthSession = resultAuth as AWSCognitoAuthSession
                        Log.d(TAG_AUTH_MANAGER, awsAuthSession.toString())
                        handler.post {
                            result.success(awsAuthSession.isSignedIn)
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    }
            )
        }

        fun getUsername(result: MethodChannel.Result) {
            Amplify.Auth.fetchAuthSession(
                    { resultAuth ->
                        val awsAuthSession = resultAuth as AWSCognitoAuthSession
                        if (awsAuthSession.isSignedIn) {
                            handler.post {
                                Log.d(TAG_AUTH_MANAGER, "User name: ${Amplify.Auth.currentUser.username}")
                                result.success(Amplify.Auth.currentUser.username)
                            }
                        } else {
                            handler.post {
                                Log.e(TAG_AUTH_MANAGER, "User not signed")
                                result.error(TAG_ERROR, "Error user not signed", "")
                            }
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                    }
            )
        }

        fun postApi(result: MethodChannel.Result, apiName: String, tokenUser: String, path: String, body: Map<String, Any>) {
            callApi(MethodCallApi.POST, result, apiName, tokenUser, path, body)
        }

        fun putApi(result: MethodChannel.Result, apiName: String, tokenUser: String, path: String, body: Map<String, Any>) {
            callApi(MethodCallApi.PUT, result, apiName, tokenUser, path, body)
        }

        fun getApi(result: MethodChannel.Result, apiName: String, tokenUser: String, path: String, body: Map<String, Any>) {
            callApi(MethodCallApi.GET, result, apiName, tokenUser, path, body)
        }

        fun deleteApi(result: MethodChannel.Result, apiName: String, tokenUser: String, path: String, body: Map<String, Any>) {
            callApi(MethodCallApi.DELETE, result, apiName, tokenUser, path, body)
        }

        fun authenWithSocialNetwork(result: MethodChannel.Result, activity: Activity, type: String) {

            val authProvider = if (type == "apple") {
                AuthProvider.apple()
            } else {
                AuthProvider.google()
            }
            Amplify.Auth.signInWithSocialWebUI(
                    authProvider,
                    activity,
                    { resultAuth ->
                        handler.post {
                            Log.d(TAG_AUTH_SIGN_IN, "SignInWebUI $type: $resultAuth")
                            result.success(true)
                        }
                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_SIGN_IN)
                    }
            )
        }

        fun updateUserPhone(result: MethodChannel.Result, userPhone: String) {
            val userPhoneAttribute = AuthUserAttribute(AuthUserAttributeKey.phoneNumber(), userPhone)
            Amplify.Auth.updateUserAttribute(userPhoneAttribute,
                    { resultUpdate ->
                        handler.post {
                            Log.d(TAG_AUTH_MANAGER, "Updated user attribute = $resultUpdate")
                            result.success(true)
                        }
                    },
                    { error -> handlerErrorAuthException(error, result, TAG_AUTH_MANAGER) }
            )
        }

        fun confirmUpdateUserPhone(result: MethodChannel.Result, confirmCode: String) {
            Amplify.Auth.confirmUserAttribute(AuthUserAttributeKey.phoneNumber(), confirmCode,
                    {
                        handler.post {
                            Log.d(TAG_AUTH_MANAGER, "Confirmed user attribute with correct code.")
                            result.success(true)
                        }
                    },
                    { error -> handlerErrorAuthException(error, result, TAG_AUTH_MANAGER) }
            )
        }

        fun resendConfirmCodeUpdateUserPhone(result: MethodChannel.Result) {
            Amplify.Auth.resendUserAttributeConfirmationCode(AuthUserAttributeKey.phoneNumber(),
                    {
                        handler.post {
                            Log.d(TAG_AUTH_MANAGER, "Code was resent: $it.")
                            result.success(true)
                        }
                    },
                    { error -> handlerErrorAuthException(error, result, TAG_AUTH_MANAGER) }
            )
        }

        private fun callApi(methodCall: MethodCallApi, result: MethodChannel.Result, apiName: String, tokenUser: String, path: String, body: Map<String, Any>) {

            val headerMap = mutableMapOf<String, String>()
            headerMap["Content-Type"] = "application/json"
            val restOptionsBuilder = RestOptions.builder()
            restOptionsBuilder.addPath(path)
            if (body.isNotEmpty()) {
                restOptionsBuilder.addBody(Gson().toJson(body).toByteArray())
            }
            // Check user Token
            if (tokenUser.isNotEmpty()) {
                headerMap["Authorization"] = tokenUser
                restOptionsBuilder.addHeaders(headerMap)
                requestCallApi(methodCall, result, apiName, restOptionsBuilder)
            } else {
                // Check user signOut globally
                checkUserSignOutGlobally(result) {
                    if (it) {
                        Log.e(TAG_AUTH_MANAGER, MESSAGE_USER_TOKEN_INVALID)
                        handler.post {
                            result.error(ERROR_CODE_UNKNOWN, MESSAGE_USER_TOKEN_INVALID, "")
                        }
                    } else {
                        requestCallApi(methodCall, result, apiName, restOptionsBuilder)
                    }
                }
            }


        }

        private fun requestCallApi(methodCall: MethodCallApi, result: MethodChannel.Result, apiName: String, restOptionsBuilder: Builder) {
            val succeedCallback = Consumer<RestResponse> { response -> handlerApiSucceed(result, methodCall.tag, response) }
            val errorCallback = Consumer<ApiException> { apiFailure -> handlerApiException(result, methodCall.tag, apiFailure) }
            when (methodCall) {
                MethodCallApi.GET -> Amplify.API.get(apiName, restOptionsBuilder.build(), succeedCallback, errorCallback)

                MethodCallApi.POST -> Amplify.API.post(apiName, restOptionsBuilder.build(), succeedCallback, errorCallback)

                MethodCallApi.PUT -> Amplify.API.put(apiName, restOptionsBuilder.build(), succeedCallback, errorCallback)

                MethodCallApi.DELETE -> Amplify.API.delete(apiName, restOptionsBuilder.build(), succeedCallback, errorCallback)
            }
        }

        private fun handlerApiSucceed(result: MethodChannel.Result, tag: String, response: RestResponse) {
            handler.post {
                Log.d(tag, "Response: ${response.data.asString()}")
                result.success(response.data.asString())
            }
        }

        private fun handlerApiException(result: MethodChannel.Result, tag: String, apiFailure: ApiException) {
            handler.post {
                Log.e(tag, apiFailure.toString())
                result.error(ERROR_CODE_API, apiFailure.toString(), apiFailure.toString())
            }
        }

        private fun checkUserSignOutGlobally(result: MethodChannel.Result, checkResultCallBack: (Boolean) -> Unit) {
            Amplify.Auth.fetchAuthSession(
                    { resultAuth ->
                        val awsAuthSession = resultAuth as AWSCognitoAuthSession
                        Log.d(TAG_AUTH_MANAGER, awsAuthSession.toString())
                        val userPoolTokens = awsAuthSession.userPoolTokens.value
                        checkResultCallBack.invoke(awsAuthSession.isSignedIn && userPoolTokens == null)

                    },
                    { error ->
                        handlerErrorAuthException(error, result, TAG_AUTH_MANAGER)
                        checkResultCallBack.invoke(true)
                    }
            )
        }

        private fun convertAuthSignInStep(authSignInStep: AuthSignInStep): String {
            return when (authSignInStep) {
                AuthSignInStep.CONFIRM_SIGN_IN_WITH_SMS_MFA_CODE -> "CONFIRM_SIGN_IN_WITH_SMS_MFA_CODE"
                AuthSignInStep.CONFIRM_SIGN_IN_WITH_CUSTOM_CHALLENGE -> "CONFIRM_SIGN_IN_WITH_CUSTOM_CHALLENGE"
                AuthSignInStep.CONFIRM_SIGN_IN_WITH_NEW_PASSWORD -> "CONFIRM_SIGN_IN_WITH_NEW_PASSWORD"
                AuthSignInStep.RESET_PASSWORD -> "RESET_PASSWORD"
                AuthSignInStep.CONFIRM_SIGN_UP -> "CONFIRM_SIGN_UP"
                AuthSignInStep.DONE -> "DONE"
                else -> "Not support"
            }
        }

        private fun convertAuthResetPasswordStep(authResetPasswordStep: AuthResetPasswordStep): String {
            return when (authResetPasswordStep) {
                AuthResetPasswordStep.CONFIRM_RESET_PASSWORD_WITH_CODE -> "CONFIRM_RESET_PASSWORD_WITH_CODE"
                AuthResetPasswordStep.DONE -> "DONE"
                else -> "Not support"
            }
        }

        private fun getErrorCodeFromAuthException(error: AuthException): String {
            return when (error.cause) {
                is ResourceNotFoundException -> ERROR_CODE_RESOURCE_NOT_FOUND_EXCEPTION
                is CodeMismatchException -> ERROR_CODE_CODE_MISMATCH_EXCEPTION
                is InvalidParameterException -> ERROR_CODE_INVALID_PARAMETER_EXCEPTION
                is UnexpectedLambdaException -> ERROR_CODE_UNEXPECTED_LAMBDA_EXCEPTION
                is UserLambdaValidationException -> ERROR_CODE_USER_LAMBDA_VALIDATION_EXCEPTION
                is InvalidPasswordException -> ERROR_CODE_INVALID_PASSWORD_EXCEPTION
                is UsernameExistsException -> ERROR_CODE_USERNAME_EXISTS_EXCEPTION
                is CodeDeliveryFailureException -> ERROR_CODE_CODE_DELIVERY_FAILURE_EXCEPTION
                is NotAuthorizedException -> ERROR_CODE_NOT_AUTHORIZED_EXCEPTION
                is TooManyFailedAttemptsException -> ERROR_CODE_TOO_MANY_FAILED_ATTEMPTS_EXCEPTION
                is ExpiredCodeException -> ERROR_CODE_EXPIRED_CODE_EXCEPTION
                is InvalidLambdaResponseException -> ERROR_CODE_INVALID_LAMBDA_RESPONSE_EXCEPTION
                is AliasExistsException -> ERROR_CODE_ALIAS_EXISTS_EXCEPTION
                is TooManyRequestsException -> ERROR_CODE_TOO_MANY_REQUESTS_EXCEPTION
                is LimitExceededException -> ERROR_CODE_LIMIT_EXCEEDED_EXCEPTION
                is UserNotFoundException -> ERROR_CODE_USER_NOT_FOUND_EXCEPTION
                is InternalErrorException -> ERROR_CODE_INTERNAL_ERROR_EXCEPTION
                else -> ERROR_CODE_DEFAULT
            }
        }

        private fun handlerErrorAuthException(error: AuthException, result: MethodChannel.Result, tag: String) {
            Log.e(tag, error.toString())
            val errorCode = getErrorCodeFromAuthException(error)
            handler.post {
                result.error(errorCode, error.toString(), error.toString())
            }
        }

    }


}