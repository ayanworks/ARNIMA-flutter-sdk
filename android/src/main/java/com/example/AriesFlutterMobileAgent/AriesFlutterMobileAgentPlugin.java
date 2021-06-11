/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
package com.example.AriesFlutterMobileAgent;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.system.ErrnoException;
import android.system.Os;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AriesFlutterMobileAgentPlugin
 */
@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class AriesFlutterMobileAgentPlugin implements FlutterPlugin, MethodCallHandler {
    AriesFlutterMobileAgent FlutterMobileAgent = new AriesFlutterMobileAgent();
   
    private MethodChannel channel;
    private Context context;

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "AriesFlutterMobileAgent");
        channel.setMethodCallHandler(new AriesFlutterMobileAgentPlugin());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "AriesFlutterMobileAgent");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                Os.setenv("EXTERNAL_STORAGE", context.getExternalFilesDir(null).getAbsolutePath(), true);
            }
            System.loadLibrary("indy");
        } catch (ErrnoException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result rawResult) {
        Result result = new MethodResultWrapper(rawResult);
        String configJson;
        String credentialJson;
        String signerVk;
        byte[] messageRaw;
        switch (call.method) {
            case "createWallet":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                FlutterMobileAgent.createWallet(configJson, credentialJson, result);
                break;
            case "createAndStoreMyDids":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                String didJson = call.argument("didJson");
                Boolean createMasterSecret = call.argument("createMasterSecret");
                FlutterMobileAgent.createAndStoreMyDids(configJson, credentialJson, didJson, createMasterSecret, result);
                break;
            case "createPoolLedgerConfig":
                String poolConfig = call.argument("poolConfig");
                FlutterMobileAgent.createPoolLedgerConfig(poolConfig, result);
                break;
            case "addWalletRecord":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                String type = call.argument("type");
                String id = call.argument("id");
                String value = call.argument("value");
                String tags = call.argument("tags");
                FlutterMobileAgent.addWalletRecord(configJson, credentialJson, type, id, value, tags, result);
                break;

            case "packMessage":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                byte[] payload = call.argument("payload");
                ArrayList<String> recipientKeys = call.argument("recipientKeys");
                String senderVk = call.argument("senderVk");
                FlutterMobileAgent.packMessage(configJson, credentialJson, payload, recipientKeys, senderVk, result);
                break;
            case "unpackMessage":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                payload = call.argument("payload");
                FlutterMobileAgent.unpackMessage(configJson, credentialJson, payload, result);
                break;
            case "cryptoVerify":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                signerVk = call.argument("signVerkey");
                messageRaw = call.argument("messageRaw");
                byte[] signatureRaw = call.argument("signatureRaw");
                FlutterMobileAgent.cryptoVerify(configJson, credentialJson, signerVk, messageRaw, signatureRaw, result);
                break;
            case "getCredDef":
                String submitterDid = call.argument("submitterDid");
                String credId = call.argument("credId");
                FlutterMobileAgent.getCredDef(submitterDid, credId, result);
                break;
            case "getRevocRegDef":
                submitterDid = call.argument("submitterDid");
                id = call.argument("ID");
                FlutterMobileAgent.getRevocRegDef(submitterDid, id, result);
                break;
            case "proverCreateCredentialReq":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                String proverDid = call.argument("proverDid");
                String credentialOfferJson = call.argument("credentialOfferJson");
                String credentialDefJson = call.argument("credentialDefJson");
                String masterSecretId = call.argument("masterSecretId");
                FlutterMobileAgent.proverCreateCredentialReq(configJson, credentialJson, proverDid, credentialOfferJson, credentialDefJson, masterSecretId, result);
                break;
            case "proverStoreCredential":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                credId = call.argument("credId");
                String credReqMetadataJson = call.argument("credReqMetadataJson");
                String credJson = call.argument("credJson");
                String credDefJson = call.argument("credDefJson");
                String revRegDefJson = call.argument("revRegDefJson");
                FlutterMobileAgent.proverStoreCredential(configJson, credentialJson, credId, credReqMetadataJson, credJson, credDefJson, revRegDefJson, result);
                break;
            case "proverSearchCredentialsForProofReq":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                String proofRequest = call.argument("proofRequest");
                String did = call.argument("did");
                masterSecretId = call.argument("masterSecretId");
                FlutterMobileAgent.proverSearchCredentialsForProofReq(configJson, credentialJson, proofRequest, did, masterSecretId, context, result);
                break;
            case "proverGetCredentials":
                configJson = call.argument("configJson");
                credentialJson = call.argument("credentialJson");
                String filter = call.argument("filter");
                FlutterMobileAgent.proverGetCredentials(configJson, credentialJson, filter, result);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private static class MethodResultWrapper implements Result {
        private final Result methodResult;
        private final Handler handler;

        MethodResultWrapper(Result result) {
            methodResult = result;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object result) {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.success(result);
                        }
                    }
            );
        }

        @Override
        public void error(
                final String errorCode, final String errorMessage, final Object errorDetails) {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.error(errorCode, errorMessage, errorDetails);
                        }
                    }
            );
        }

        @Override
        public void notImplemented() {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.notImplemented();
                        }
                    }
            );
        }
    }
}
