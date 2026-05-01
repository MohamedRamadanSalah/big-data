package com.example.flutter_big_data

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_big_data/asset_copier"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "copyAssetDatabase") {
                val assetName = call.argument<String>("assetName")
                val destPath = call.argument<String>("destPath")
                
                if (assetName != null && destPath != null) {
                    val outFile = File(destPath)
                    if (outFile.exists()) {
                        result.success(true)
                        return@setMethodCallHandler
                    }

                    Thread {
                        try {
                            val flutterLoader = io.flutter.FlutterInjector.instance().flutterLoader()
                            val flutterKey = flutterLoader.getLookupKeyForAsset(assetName)
                            
                            val inputStream: InputStream = context.assets.open(flutterKey)
                            val outputStream = FileOutputStream(outFile)
                            
                            val buffer = ByteArray(8192)
                            var length: Int
                            while (inputStream.read(buffer).also { length = it } > 0) {
                                outputStream.write(buffer, 0, length)
                            }
                            
                            outputStream.flush()
                            outputStream.close()
                            inputStream.close()
                            
                            android.os.Handler(android.os.Looper.getMainLooper()).post {
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            android.os.Handler(android.os.Looper.getMainLooper()).post {
                                result.error("COPY_FAILED", "Failed to copy asset database", e.message)
                            }
                        }
                    }.start()
                } else {
                    result.error("INVALID_ARGS", "assetName or destPath is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
