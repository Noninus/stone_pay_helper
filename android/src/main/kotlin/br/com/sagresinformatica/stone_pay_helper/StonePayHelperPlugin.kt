package br.com.sagresinformatica.stone_pay_helper

import androidx.annotation.NonNull
import android.app.Activity
import android.content.Context          
import android.widget.Toast
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import io.flutter.plugin.common.PluginRegistry

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

import stone.application.StoneStart;
import stone.utils.Stone;
import stone.utils.keys.StoneKeyType;
import stone.application.enums.Action;
import stone.application.interfaces.StoneActionCallback;
import br.com.stone.posandroid.providers.PosPrintProvider;
import org.json.JSONArray;
import org.json.JSONObject;

/** StonePayHelperPlugin */
class StonePayHelperPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity:Activity
  private lateinit var context: Context
  private var printerDeeplinkResult: Result? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "stone_pay_helper")
    context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(this)
  }

 
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      //Toast.makeText(activity, "Hello!",Toast.LENGTH_SHORT).show()
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "sendDeeplink") {
      sendDeeplink(
          call.argument<Int>("amount"),
          call.argument<Boolean>("editableAmount"),
          call.argument<String>("transactionType"),
          call.argument<Int>("installmentCount"),
          call.argument<String>("installmentType"),
          call.argument<Int>("orderId"),
          call.argument<String>("returnScheme")
      )
      result.success(true)
    } else if (call.method == "sendDeepLinkPrinter") {
      try {
        // Store the result to be used when the deeplink response arrives
        printerDeeplinkResult = result
        sendDeepLinkPrinter(
            call.argument<String>("printingData"),
            call.argument<String>("returnScheme"),
            call.argument<Boolean>("showFeedbackScreen")
        )

        // Add a timeout handler - if no response after timeout, return TIMEOUT error
        // The printer should always return a response
        val timeout = 30000L // 30 seconds timeout
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            if (printerDeeplinkResult != null) {
                Log.e(TAG, "Printer deeplink timeout - no response received")
                printerDeeplinkResult?.error("TIMEOUT", "No response from printer app", null)
                printerDeeplinkResult = null
            }
        }, timeout)

        // IMPORTANT: Don't call result.success() here since we're waiting for the callback
        // The result will be sent when handleDeepLinkResponse is called

      } catch (e: Exception) {
        Log.e(TAG, "Error sending deeplink printer: ${e.message}")
        printerDeeplinkResult = null
        result.error("DEEPLINK_ERROR", "Failed to send deeplink: ${e.message}", null)
      }
    } else if (call.method == "enableDebugMode") {
      val enable = call.argument<Boolean>("enable") ?: true
      Log.d(TAG, "Stone Debug logging enabled: $enable")
      result.success(true)
    } else if (call.method == "initStone") {
      val qrcodeAuthorization = call.argument<String>("qrcodeAuthorization")
      val qrcodeProviderId = call.argument<String>("qrcodeProviderId")

      if (qrcodeAuthorization != null || qrcodeProviderId != null) {
        val stoneKeys = HashMap<StoneKeyType, String>()

        if (qrcodeAuthorization != null) {
          stoneKeys[StoneKeyType.QRCODE_AUTHORIZATION] = qrcodeAuthorization
        }
        if (qrcodeProviderId != null) {
          stoneKeys[StoneKeyType.QRCODE_PROVIDERID] = qrcodeProviderId
        }

        StoneStart.init(context, stoneKeys)
        Log.d(TAG, "Stone initialized with keys")
      } else {
        StoneStart.init(context)
        Log.d(TAG, "Stone initialized without keys")
      }

      result.success(true)
    } else if (call.method == "printBase64") {
      val posPrintProvider = PosPrintProvider(context)
      posPrintProvider.addBase64Image(call.argument<String>("base64").orEmpty())
      addCallBack(posPrintProvider)
      posPrintProvider.execute()

      result.success(true)
    } else if (call.method == "printText") {
      val posPrintProvider = PosPrintProvider(context)
      posPrintProvider.addLine(call.argument<String>("text").orEmpty())
      addCallBack(posPrintProvider)
      posPrintProvider.execute()

      result.success(true)
    } else if (call.method == "printFromJson") {
      try {
        val printingData = call.argument<String>("printingData").orEmpty()
        val posPrintProvider = PosPrintProvider(context)
        val jsonArray = JSONArray(printingData)

        for (i in 0 until jsonArray.length()) {
          val item = jsonArray.getJSONObject(i)
          val type = item.optString("type", "")
          val content = item.optString("content", "")

          when (type) {
            "text" -> posPrintProvider.addLine(content)
            "line" -> posPrintProvider.addLine(content)
            "image" -> {
              val imagePath = item.optString("imagePath", "")
              if (imagePath.isNotEmpty()) {
                try {
                  val file = java.io.File(imagePath)
                  if (file.exists()) {
                    val bytes = file.readBytes()
                    val base64Str = android.util.Base64.encodeToString(bytes, android.util.Base64.NO_WRAP)
                    posPrintProvider.addBase64Image(base64Str)
                  } else {
                    Log.w(TAG, "printFromJson - Image file not found: $imagePath")
                    posPrintProvider.addLine("[image: $imagePath]")
                  }
                } catch (e: Exception) {
                  Log.e(TAG, "printFromJson - Error loading image: ${e.message}")
                  posPrintProvider.addLine("[image error]")
                }
              }
            }
          }
        }

        addCallBack(posPrintProvider)
        posPrintProvider.execute()
        result.success("SUCCESS")
      } catch (e: Exception) {
        Log.e(TAG, "printFromJson error: ${e.message}")
        result.error("PRINT_SDK_ERROR", "Failed to print via SDK: ${e.message}", null)
      }
    } else if (call.method == "isStone") {
      val isStone = Stone.getPosAndroidDevice().getPosAndroidManufacturer()
      if (isStone == null) {
        result.error("ec_null", "Couldn't retrieve ec", null)
      }
      result.success(isStone)
    } else if (call.method == "getEc") {
      val ec = Stone.getPosAndroidDevice().getPosAndroidManufacturer()
      if (ec == null) {
        result.error("ec_null", "Couldn't retrieve ec", null)
      }
      result.success(ec)
    } else {
      result.notImplemented()
    }
  }

  private fun addCallBack(posPrintProvider: PosPrintProvider){
    posPrintProvider.connectionCallback = object : StoneActionCallback {
      override fun onSuccess() {
        // Toast.makeText(activity, "Recibo impresso", Toast.LENGTH_SHORT).show();
        channel.invokeMethod("printerCallback", "success")
      }
      override fun onError() {
        // Toast.makeText(activity, "error: " + posPrintProvider.getListOfErrors(), Toast.LENGTH_SHORT).show();
        channel.invokeMethod("printerCallback", "error: " + posPrintProvider.getListOfErrors())
      }
      override fun onStatusChanged(action: Action?) {
        // Toast.makeText(activity, "onStatusChanged: " + action?.name, Toast.LENGTH_SHORT).show();
        // channel.invokeMethod("printerCallback", "status: " + action?.name)
      }
    }
  }


  
    private fun sendDeeplink(
        amount: Int?,
        editableAmount: Boolean?,
        transactionType: String?,
        installmentCount: Int?,
        installmentType: String?,
        orderId: Int?,
        returnScheme: String?
    ) {

        val uriBuilder = Uri.Builder()
        uriBuilder.authority("pay")
        uriBuilder.scheme("payment-app")
        

        if (returnScheme != null) {
          uriBuilder.appendQueryParameter(RETURN_SCHEME, returnScheme)
        } else {
          uriBuilder.appendQueryParameter(RETURN_SCHEME, "flutterdeeplinkdemo")
        }


        uriBuilder.appendQueryParameter(EDITABLE_AMOUNT, if (editableAmount == true) "1" else "0")

        if (amount != null) {
            uriBuilder.appendQueryParameter(AMOUNT, amount.toLong().toString())
        }

        if (transactionType != null) {
            uriBuilder.appendQueryParameter(TRANSACTION_TYPE, transactionType)
        }

        if (installmentType != null) {
            uriBuilder.appendQueryParameter(INSTALLMENT_TYPE, installmentType)
        }

        if (installmentCount != null) {
            uriBuilder.appendQueryParameter(INSTALLMENT_COUNT, installmentCount.toString())
        }

        if (orderId != null) {
            uriBuilder.appendQueryParameter(ORDER_ID, orderId.toLong().toString())
        }

        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.data = uriBuilder.build()
        activity.startActivity(intent)

        Log.v(TAG, "toUri(scheme = ${intent.data})")
    }

    private fun sendDeepLinkPrinter(
        printingData: String?,
        returnScheme: String?,
        showFeedbackScreen: Boolean?
    ) {
        Log.d(TAG, "sendDeepLinkPrinter - Starting")
        Log.d(TAG, "sendDeepLinkPrinter - printingData length: ${printingData?.length}")
        Log.d(TAG, "sendDeepLinkPrinter - returnScheme: $returnScheme")
        Log.d(TAG, "sendDeepLinkPrinter - showFeedbackScreen: $showFeedbackScreen")

        val uriBuilder = Uri.Builder()
        uriBuilder.authority("print")
        uriBuilder.scheme("printer-app")

        // Use the showFeedbackScreen parameter to control the feedback screen
        val feedbackValue = if (showFeedbackScreen == true) "true" else "false"
        uriBuilder.appendQueryParameter("SHOW_FEEDBACK_SCREEN", feedbackValue)

        if (returnScheme != null) {
            uriBuilder.appendQueryParameter("SCHEME_RETURN", returnScheme)
        } else {
            uriBuilder.appendQueryParameter("SCHEME_RETURN", "flutterdeeplinkdemo")
        }

        if (printingData != null) {
            uriBuilder.appendQueryParameter("PRINTABLE_CONTENT", printingData)
        }

        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.data = uriBuilder.build()

        Log.d(TAG, "sendDeepLinkPrinter - Full URI: ${intent.data}")

        // Verificar se existe algum app que pode responder ao deeplink
        val packageManager = activity.packageManager
        val activities = packageManager.queryIntentActivities(intent, 0)

        Log.d(TAG, "sendDeepLinkPrinter - Found ${activities.size} apps that can handle this deeplink")

        for (activity in activities) {
            Log.d(TAG, "sendDeepLinkPrinter - Available app: ${activity.activityInfo.packageName}")
        }

        if (activities.isNotEmpty()) {
            activity.startActivity(intent)
            Log.d(TAG, "sendDeepLinkPrinter - Deeplink sent successfully")
        } else {
            Log.e(TAG, "sendDeepLinkPrinter - No app found to handle printer deeplink")
            throw Exception("No app found to handle printer deeplink")
        }
    }

    private fun handleDeepLinkResponse(intent: Intent) {
       Log.v(TAG, "handleDeepLinkResponse")
        try {
            if (intent?.data != null) {
                val data = intent.data.toString()
                Log.v(TAG, "DeepLink Response: $data")

                // Parse the URI to extract parameters
                val uri = Uri.parse(data)

                // Check multiple possible parameter names for printer result
                // Different Stone printer apps may use different parameter names
                val printResult = uri.getQueryParameter("print_result")
                    ?: uri.getQueryParameter("PRINT_RESULT")
                    ?: uri.getQueryParameter("result")
                    ?: uri.getQueryParameter("RESULT")
                    ?: uri.getQueryParameter("status")
                    ?: uri.getQueryParameter("STATUS")

                // Check if this is a printer response
                if (printResult != null || data.contains("printer-app") || data.contains("print")) {
                    // This is a printer response
                    Log.d(TAG, "Printer DeepLink Response - Result: ${printResult ?: "UNKNOWN"}")

                    // If we have a pending printer result, return it
                    if (printerDeeplinkResult != null) {
                        // If we couldn't extract a specific result, but it's clearly a printer response, return SUCCESS
                        val finalResult = printResult ?: if (data.contains("success", ignoreCase = true)) "SUCCESS" else "UNKNOWN_RESULT"
                        printerDeeplinkResult?.success(finalResult)
                        printerDeeplinkResult = null
                    } else {
                        Log.w(TAG, "Received printer response but no pending result handler")
                    }
                } else if (data.contains("pay-response")) {
                    // Regular checkout callback
                    channel.invokeMethod("checkoutCallback", data)
                } else {
                    Log.w(TAG, "Received unknown deeplink response: $data")
                    // If we have a pending printer result and received any response, assume it's from printer
                    if (printerDeeplinkResult != null) {
                        Log.d(TAG, "Assuming this is a printer response since we're waiting for one")
                        printerDeeplinkResult?.success("RESPONSE_RECEIVED")
                        printerDeeplinkResult = null
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling deeplink response: ${e.message}")
            if (printerDeeplinkResult != null) {
                printerDeeplinkResult?.error("RESPONSE_ERROR", "Error handling deeplink response: ${e.message}", null)
                printerDeeplinkResult = null
            }
            Log.v(TAG, e.toString())
        }
    }

  


    companion object {
        private const val AMOUNT = "amount"
        private const val ORDER_ID = "order_id"
        private const val EDITABLE_AMOUNT = "editable_amount"
        private const val TRANSACTION_TYPE = "transaction_type"
        private const val INSTALLMENT_TYPE = "installment_type"
        private const val INSTALLMENT_COUNT = "installment_count"
        private const val RETURN_SCHEME = "return_scheme"
        private const val TAG = "SendDeeplinkPayment"
    }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
    binding.addOnNewIntentListener(fun(intent: Intent?): Boolean {
      Log.d(TAG, "onNewIntent received")
      intent?.let {
        Log.d(TAG, "Intent data: ${it.data}")
        Log.d(TAG, "Intent action: ${it.action}")
        Log.d(TAG, "Intent scheme: ${it.scheme}")
        handleDeepLinkResponse(it)
      }
      return false;
    })

    // Check if there's already an intent when attaching (app was opened via deeplink)
    if (binding.activity.intent?.data != null) {
      Log.d(TAG, "Initial intent data: ${binding.activity.intent.data}")
      Log.d(TAG, "Initial intent action: ${binding.activity.intent.action}")
      Log.d(TAG, "Initial intent scheme: ${binding.activity.intent.scheme}")

      // Check if this is a response from printer (activity was recreated after printer app)
      val data = binding.activity.intent.data.toString()
      if (data.contains("flutterdeeplinkdemo") || data.contains("print") || data.contains("printer")) {
        Log.d(TAG, "Detected printer response on activity attach")
        handleDeepLinkResponse(binding.activity.intent)
      }
    }
  }
  override fun onDetachedFromActivityForConfigChanges() {}

}
