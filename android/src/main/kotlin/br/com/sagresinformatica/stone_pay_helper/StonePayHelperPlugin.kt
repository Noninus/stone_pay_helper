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
import stone.application.StoneStart;
import stone.utils.Stone;

import br.com.stone.posandroid.providers.PosPrintProvider;

/** StonePayHelperPlugin */
class StonePayHelperPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity:Activity
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "stone_pay_helper")
    context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(this)
  }

 
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      Toast.makeText(activity, "Hello!",Toast.LENGTH_SHORT).show()
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
    } else if (call.method == "initStone") {
      StoneStart.init(context)
      //Stone.appName = "StoneDemo"
      result.success(true)
    } else if (call.method == "printBase64") {
      val posPrintProvider = PosPrintProvider(context)
      posPrintProvider.addBase64Image(call.argument<String>("base64").orEmpty())
      posPrintProvider.execute()

      result.success(true)
    } else if (call.method == "printText") {
      val posPrintProvider = PosPrintProvider(context)
      posPrintProvider.addLine(call.argument<String>("text").orEmpty())
      posPrintProvider.execute()

      result.success(true)
    }else {
      result.notImplemented()
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
        uriBuilder.appendQueryParameter(RETURN_SCHEME, "flutterdeeplinkdemo")
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

    private fun handleDeepLinkResponse(intent: Intent) {
       Log.v(TAG, "handleDeepLinkResponse")
        try {
            if (intent?.data != null) {
                Toast.makeText(activity, intent.data.toString(), Toast.LENGTH_LONG).show()
                channel.invokeMethod("checkoutCallback", intent.data.toString())
                Log.v(TAG, intent.data.toString())
            }
        } catch (e: Exception) {
            Toast.makeText(activity, e.toString(), Toast.LENGTH_LONG).show()
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
      intent?.let { handleDeepLinkResponse(it) }
      return false;
    })
    handleDeepLinkResponse(binding.activity.intent)
  }
  override fun onDetachedFromActivityForConfigChanges() {}

}
