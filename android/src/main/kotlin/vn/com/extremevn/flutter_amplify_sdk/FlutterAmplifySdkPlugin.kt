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
import android.util.Log
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterAmplifySdkPlugin */
public class FlutterAmplifySdkPlugin : FlutterPlugin, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_amplify_sdk")
//        channel.setMethodCallHandler(AmplifyMethodChannelHandler(flutterPluginBinding.applicationContext, activity));
        context = flutterPluginBinding.applicationContext
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_amplify_sdk")
            channel.setMethodCallHandler(AmplifyMethodChannelHandler(registrar.context(), registrar.activity()))
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        Log.d("FlutterAmplifySdkPlugin", "onDetachedFromActivity")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d("FlutterAmplifySdkPlugin", "onReattachedToActivityForConfigChanges")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.getActivity();
        channel.setMethodCallHandler(AmplifyMethodChannelHandler(context, activity));
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d("FlutterAmplifySdkPlugin", "onDetachedFromActivityForConfigChanges")
    }
}
