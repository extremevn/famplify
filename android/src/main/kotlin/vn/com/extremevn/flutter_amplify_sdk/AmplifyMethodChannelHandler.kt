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
import android.net.ConnectivityManager
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AmplifyMethodChannelHandler(private val context: Context, private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        private const val NETWORK_ERROR_CODE = "NetworkException"
        private const val NETWORK_ERROR_TAG = "Amplify Network"
        private const val NETWORK_ERROR_MESSAGE = "Error checking network connection"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!isNetworkConnected(context)) {
            Log.e(NETWORK_ERROR_TAG, NETWORK_ERROR_MESSAGE)
            result.error(NETWORK_ERROR_CODE, NETWORK_ERROR_MESSAGE, "")
            return
        }
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "initialize" -> AmplifyImplement.initialize(context, result)
            "signUp" -> AmplifyImplement.signUp(result, call.argument<String>("username")!!,
                    call.argument<String>("password")!!,
                    call.argument<Map<String, String>>("userAttributes")!!)
            "confirmSignUp" -> AmplifyImplement.confirmSignUp(
                    result,
                    call.argument<String>("username")!!,
                    call.argument<String>("code")!!
            )
            "signIn" -> AmplifyImplement.signIn(
                    result,
                    call.argument<String>("username")!!,
                    call.argument<String>("password")!!
            )
            "resendSignUpCode" -> AmplifyImplement.resendSignUpCode(
                    result,
                    call.argument<String>("username")!!
            )
            "resetPassword" -> AmplifyImplement.resetPassword(
                    result,
                    call.argument<String>("username")!!
            )
            "confirmResetPassword" -> AmplifyImplement.confirmResetPassword(
                    result,
                    call.argument<String>("newPassword")!!,
                    call.argument<String>("confirmationCode")!!
            )
            "changePassword" -> AmplifyImplement.changePassword(
                    result,
                    call.argument<String>("oldPassword")!!,
                    call.argument<String>("newPassword")!!
            )
            "signOut" -> AmplifyImplement.signOut(result)
            "signOutGlobally" -> AmplifyImplement.signOutGlobally(result)
            "getTokens" -> AmplifyImplement.getTokens(result)
            "getCredentials" -> AmplifyImplement.getCredentials(result)
            "getIdentityId" -> AmplifyImplement.getIdentityId(result)
            "isSignedIn" -> AmplifyImplement.isSignedIn(result)
            "getUsername" -> AmplifyImplement.getUsername(result)
            "postApi" -> AmplifyImplement.postApi(
                    result,
                    call.argument<String>("apiName")!!,
                    call.argument<String>("tokenUser")!!,
                    call.argument<String>("path")!!,
                    call.argument<Map<String, Any>>("body")!!
            )
            "putApi" -> AmplifyImplement.putApi(
                    result,
                    call.argument<String>("apiName")!!,
                    call.argument<String>("tokenUser")!!,
                    call.argument<String>("path")!!,
                    call.argument<Map<String, Any>>("body")!!
            )
            "getApi" -> AmplifyImplement.getApi(
                    result,
                    call.argument<String>("apiName")!!,
                    call.argument<String>("tokenUser")!!,
                    call.argument<String>("path")!!,
                    call.argument<Map<String, Any>>("body")!!
            )
            "deleteApi" -> AmplifyImplement.deleteApi(
                    result,
                    call.argument<String>("apiName")!!,
                    call.argument<String>("tokenUser")!!,
                    call.argument<String>("path")!!,
                    call.argument<Map<String, Any>>("body")!!
            )
            "authenWithSocialNetwork" -> AmplifyImplement.authenWithSocialNetwork(result, activity, call.argument<String>("type")!!)
            "updateUserPhone" -> AmplifyImplement.updateUserPhone(
                    result,
                    call.argument<String>("userPhone")!!
            )
            "confirmUpdateUserPhone" -> AmplifyImplement.confirmUpdateUserPhone(
                    result,
                    call.argument<String>("confirmCode")!!
            )
            "resendConfirmCodeUpdateUserPhone" -> AmplifyImplement.resendConfirmCodeUpdateUserPhone(
                    result
            )
            else -> result.notImplemented()
        }
    }

    private fun isNetworkConnected(context: Context): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager?
        return cm!!.activeNetworkInfo != null && cm.activeNetworkInfo.isConnected
    }

}