package vn.extremevn.flutter_amplify_sdk_example

import android.content.Intent
import android.util.Log
import com.amplifyframework.core.Amplify
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.scheme != null && "test" == intent.scheme) {
            Amplify.Auth.handleWebUISignInResponse(intent)
        }
    }
}
