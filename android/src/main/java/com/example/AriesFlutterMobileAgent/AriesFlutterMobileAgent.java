/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
package com.example.AriesFlutterMobileAgent;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Environment;
import android.util.Log;

import com.google.gson.Gson;

import org.hyperledger.indy.sdk.IndyException;
import org.hyperledger.indy.sdk.anoncreds.Anoncreds;
import org.hyperledger.indy.sdk.anoncreds.AnoncredsResults;
import org.hyperledger.indy.sdk.anoncreds.CredentialsSearchForProofReq;
import org.hyperledger.indy.sdk.blob_storage.BlobStorageReader;
import org.hyperledger.indy.sdk.crypto.Crypto;
import org.hyperledger.indy.sdk.did.Did;
import org.hyperledger.indy.sdk.did.DidResults;
import org.hyperledger.indy.sdk.ledger.Ledger;
import org.hyperledger.indy.sdk.ledger.LedgerResults;
import org.hyperledger.indy.sdk.non_secrets.WalletRecord;
import org.hyperledger.indy.sdk.pool.Pool;
import org.hyperledger.indy.sdk.pool.PoolJSONParameters;
import org.hyperledger.indy.sdk.wallet.Wallet;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.ExecutionException;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class AriesFlutterMobileAgent extends FlutterActivity {

    public static final int PROTOCOL_VERSION = 2;
    private static final String DEFAULT_POOL_NAME = "pool";

    public void createPoolLedgerConfig(String poolConfig, MethodChannel.Result result) {
        new CreatePoolLedgerConfig().execute(poolConfig, result);
    }

    public Pool openPoolLedger(String poolConfig, MethodChannel.Result result) {
        Pool pool = null;
        try {
            pool = Pool.openPoolLedger(DEFAULT_POOL_NAME, poolConfig).get();
            return pool;
        } catch (Exception e) {
            IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
            result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            return null;
        }
    }

    public void closePoolLedger(Pool pool) {
        try {
            pool.closePoolLedger().get();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        } catch (IndyException e) {
            e.printStackTrace();
        }
    }

    public void createWallet(String configJson, String credentialsJson, MethodChannel.Result result) {
        new CreateWallet().execute(configJson, credentialsJson, result);
    }

    public Wallet openWallet(String configJson, String credentialsJson, MethodChannel.Result result) {
        Wallet wallet = null;
        try {
            wallet = Wallet.openWallet(configJson, credentialsJson).get();
        } catch (Exception e) {
            IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
            result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
        } finally {
            return wallet;
        }
    }

    public void closeWallet(Wallet wallet) {
        try {
            wallet.closeWallet().get();
        } catch (IndyException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
    }

    public void createAndStoreMyDids(String configJson, String credentialsJson, String didJson,
                                     Boolean createMasterSecret, MethodChannel.Result result) {
        new CreateAndStoreMyDids().execute(configJson, credentialsJson, didJson, createMasterSecret, result);
    }

    public void addWalletRecord(String configJson, String credentialsJson, String type, String id, String value, String tags,
                                MethodChannel.Result result) {
        new AddWalletRecord().execute(configJson, credentialsJson, type, id, value, tags, result);
    }

    public void packMessage(String configJson, String credentialsJson, byte[] message,
                            ArrayList<String> receiverKeys, String senderVk, MethodChannel.Result result) {
        new PackMessage().execute(configJson, credentialsJson, message, receiverKeys, senderVk, result);
    }

    public void unpackMessage(String configJson, String credentialsJson, byte[] jwe, MethodChannel.Result result) {
        new UnpackMessage().execute(configJson, credentialsJson, jwe, result);
    }

    public void cryptoSign(String configJson, String credentialsJson, String signerVk, byte[] messageRaw,
                           MethodChannel.Result result) {
        new cryptoSign().execute(configJson, credentialsJson, signerVk, messageRaw, result);
    }

    public void cryptoVerify(String configJson, String credentialsJson, String signerVk, byte[] messageRaw,
                             byte[] signatureRaw, MethodChannel.Result result) {
        new CryptoVerify().execute(configJson, credentialsJson, signerVk, messageRaw, signatureRaw, result);
    }

    public void getCredDef(String submitterDid, String id, MethodChannel.Result result) {
        new GetCredDef().execute(submitterDid, id, result);
    }

    public void proverCreateCredentialReq(String configJson, String credentialsJson, String proverDid,
                                          String credentialOfferJson, String credentialDefJson, String masterSecretId, MethodChannel.Result result) {
        new ProverCreateCredentialReq().execute(configJson, credentialsJson, proverDid, credentialOfferJson,
                credentialDefJson, masterSecretId, result);
    }

    public void getRevocRegDef(String submitterDid, String id, MethodChannel.Result result) {
        new GetRevocRegDef().execute(submitterDid, id, result);
    }

    public void proverStoreCredential(String configJson, String credentialsJson, String credId,
                                      String credReqMetadataJson, String credJson, String credDefJson, String revRegDefJson, MethodChannel.Result result) {
        new ProverStoreCredential().execute(configJson, credentialsJson, credId, credReqMetadataJson, credJson,
                credDefJson, revRegDefJson, result);
    }

    public void proverSearchCredentialsForProofReq(String configJson, String credentialsJson, String proofRequest,
                                                   String did, String masterSecret, Context context, MethodChannel.Result result) {
        new ProverSearchCredentialsForProofReq().execute(configJson, credentialsJson, proofRequest, did, masterSecret, context,
                result);
    }

    private JSONObject getSchemaJson(Pool pool, String submitterDid, String schemaId) throws Exception {
        JSONObject parseSchemaObj = new JSONObject();
        try {
            String request = Ledger.buildGetSchemaRequest(submitterDid, schemaId).get();
            String response = Ledger.submitRequest(pool, request).get();
            LedgerResults.ParseResponseResult schemaIdObject = Ledger.parseGetSchemaResponse(response).get();

            parseSchemaObj = new JSONObject(schemaIdObject.getObjectJson());

        } catch (Exception e) {
            throw new Exception(e.toString());
        }
        return parseSchemaObj;
    }

    private JSONObject getCredDefJson(Pool pool, String submitterDid, String credDefId) throws Exception {
        JSONObject parseCredObj = new JSONObject();
        try {
            String request = Ledger.buildGetCredDefRequest(submitterDid, credDefId).get();
            String response = Ledger.submitRequest(pool, request).get();
            LedgerResults.ParseResponseResult credObject = Ledger.parseGetCredDefResponse(response).get();

            parseCredObj = new JSONObject(credObject.getObjectJson());

        } catch (Exception e) {
            Log.d("Hi_eecredDef", e.toString());
            throw new Exception(e.toString());
        }
        return parseCredObj;
    }

    private JSONObject createRevocationStateObject(Pool pool, String submitterDid, String revRegId, String credRevId, Context context)
            throws Exception {
        JSONObject revocState = new JSONObject();

        try {
            String request = Ledger
                    .buildGetRevocRegDeltaRequest(submitterDid, revRegId, 0, System.currentTimeMillis() / 1000).get();
            String response = Ledger.submitRequest(pool, request).get();
            LedgerResults.ParseRegistryResponseResult revRegDeltaJson = Ledger.parseGetRevocRegDeltaResponse(response)
                    .get();

            String requestGetRevocRegDef = Ledger.buildGetRevocRegDefRequest(submitterDid, revRegId).get();
            String responseGetRevocRegDef = Ledger.submitRequest(pool, requestGetRevocRegDef).get();
            LedgerResults.ParseResponseResult revocRegDefJson = Ledger
                    .parseGetRevocRegDefResponse(responseGetRevocRegDef).get();

            String root = context.getExternalFilesDir(null).toString();

            String filePath = root + "/revoc/";

            JSONObject revRegDefObj = new JSONObject(revocRegDefJson.getObjectJson());
            String fileURL = revRegDefObj.getJSONObject("value").getString("tailsLocation");
            String fileName = revRegDefObj.getJSONObject("value").getString("tailsHash");

            int count;
            File revocPath = new File(filePath);
            if (!revocPath.exists()) {
                revocPath.mkdir();
            }

            File file = new File(filePath + "/" + fileName);
            if (!file.exists()) {
                file.createNewFile();
                URL url = new URL(fileURL);

                URLConnection connection = url.openConnection();
                connection.connect();
                int lengthOfFile = connection.getContentLength();
                InputStream input = new BufferedInputStream(url.openStream(), 8192);
                OutputStream output = new FileOutputStream(file);
                byte[] data = new byte[1024];
                long total = 0;
                while ((count = input.read(data)) != -1) {
                    total += count;
                    output.write(data, 0, count);
                }
                output.flush();
                output.close();
                input.close();
            }

            String tailsWriterConfig = new JSONObject().put("base_dir", filePath).put("uri_pattern", "").toString();
            BlobStorageReader blobStorageReaderCfg = BlobStorageReader.openReader("default", tailsWriterConfig).get();

            JSONObject revStateJson = new JSONObject(Anoncreds.createRevocationState(
                    blobStorageReaderCfg.getBlobStorageReaderHandle(), revocRegDefJson.getObjectJson(),
                    revRegDeltaJson.getObjectJson(), revRegDeltaJson.getTimestamp(), credRevId).get());

            revocState.put(String.valueOf(revRegDeltaJson.getTimestamp()), revStateJson);

        } catch (Exception e) {
            throw new Exception(e.toString());
        }
        return revocState;
    }

    public void proverGetCredentials(String configJson, String credentialsJson, String filter, MethodChannel.Result result) {
        new ProverGetCredentials().execute(configJson, credentialsJson, filter, result);
    }

    private class CreatePoolLedgerConfig extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {
            try {
                result = (MethodChannel.Result) objects[1];
                Pool.setProtocolVersion(PROTOCOL_VERSION).get();
                File file = new File(Environment.getExternalStorageDirectory() + "/" + File.separator + "temp.txn");
                file.createNewFile();
                FileWriter fw = new FileWriter(file);
                fw.write(objects[0].toString());
                fw.close();
                PoolJSONParameters.CreatePoolLedgerConfigJSONParameter createPoolLedgerConfigJSONParameter = new PoolJSONParameters.CreatePoolLedgerConfigJSONParameter(
                        file.getAbsolutePath());
                Pool.createPoolLedgerConfig(DEFAULT_POOL_NAME, createPoolLedgerConfigJSONParameter.toJson()).get();
                result.success(true);
            } catch (Exception e) {
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.getMessage(), e);
            }
            return result;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class CreateWallet extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {
            try {
                result = (MethodChannel.Result) objects[2];
                Wallet.createWallet(objects[0].toString(), objects[1].toString()).get();
                result.success("success");
            } catch (Exception e) {
                Log.d("createWallet", e.toString());
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            }
            return result;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class CreateAndStoreMyDids extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            Wallet wallet = null;
            result = (MethodChannel.Result) objects[4];
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    DidResults.CreateAndStoreMyDidResult createMyDidResult = Did
                            .createAndStoreMyDid(wallet, objects[2].toString()).get();
                    String myDid = createMyDidResult.getDid();
                    String myVerkey = createMyDidResult.getVerkey();
                    ArrayList<String> response = new ArrayList<>();
                    JSONObject config = new JSONObject(objects[0].toString());
                    response.add(myDid);
                    response.add(myVerkey);
                    if ((Boolean) objects[3]) {
                        String outputMasterSecretId = Anoncreds
                                .proverCreateMasterSecret(wallet, config.get("id").toString()).get();
                        response.add(outputMasterSecretId);
                    }
                    result.success(response);
                }
            } catch (Exception e) {
                Log.d("createAndStore", e.toString());
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class AddWalletRecord extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[6];
            Wallet wallet = null;
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    WalletRecord.add(wallet, objects[2].toString(), objects[3].toString(), objects[4].toString(), objects[5].toString()).get();
                    result.success(true);
                }
            } catch (Exception e) {
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class PackMessage extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[5];
            Wallet wallet = null;
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    byte[] buffer = (byte[]) objects[2];
                    ArrayList<String> receiverKey = (ArrayList<String>) objects[3];
                    String[] keys = new String[receiverKey.size()];
                    for (int i = 0; i < receiverKey.size(); i++) {
                        keys[i] = receiverKey.get(i);
                    }
                    Gson gson = new Gson();
                    String receiverKeysJson = gson.toJson(keys);

                    byte[] jwe = Crypto.packMessage(wallet, receiverKeysJson, (String) objects[4], buffer).get();
                    ArrayList<Integer> data = new ArrayList<>();
                    for (byte b : jwe) {
                        int i = b;
                        data.add(i);
                    }
                    result.success(data);
                }
            } catch (Exception e) {
                Log.d("erorr in pack message", e.toString());
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class UnpackMessage extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {
            result = (MethodChannel.Result) objects[3];
            Wallet wallet = null;
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    byte[] buffer = (byte[]) objects[2];
                    byte[] res = Crypto.unpackMessage(wallet, buffer).get();
                    ArrayList<Integer> data = new ArrayList<>();
                    for (byte b : res) {
                        int i = b;
                        data.add(i);
                    }
                    result.success(data);
                }
            } catch (Exception e) {
                Log.d("erorr in pack message", e.toString());
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class cryptoSign extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[4];

            Wallet wallet = null;
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    byte[] messageRaw = (byte[]) objects[3];
                    byte[] signature = Crypto.cryptoSign(wallet, objects[2].toString(), messageRaw).get();
                    ArrayList<Integer> data = new ArrayList<>();
                    for (byte b : signature) {
                        int i = b;
                        data.add(i);
                    }
                    result.success(data);
                }
            } catch (Exception e) {
                Log.d("erorr in cryptoSign", e.toString());
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }
        }
    }

    private class CryptoVerify extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[5];

            Wallet wallet = null;
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    boolean valid = Crypto.cryptoVerify(objects[2].toString(), (byte[]) objects[3], (byte[]) objects[4]).get();
                    result.success(valid);
                }
            } catch (Exception e) {
                Log.d("error in cryptoVerify", e.toString());
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class GetCredDef extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {
            result = (MethodChannel.Result) objects[2];
            Pool pool = null;
            try {
                String request = Ledger.buildGetCredDefRequest(objects[0].toString(), objects[1].toString()).get();
                pool = openPoolLedger("{}", result);
                if (pool != null) {
                    String response = Ledger.submitRequest(pool, request).get();
                    LedgerResults.ParseResponseResult credObject = Ledger.parseGetCredDefResponse(response).get();
                    result.success(credObject.getObjectJson());
                }
            } catch (Exception e) {
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (pool != null) {
                    closePoolLedger(pool);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class ProverCreateCredentialReq extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[6];
            Wallet wallet = null;
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    Log.d("ln", objects[4].toString());
                    AnoncredsResults.ProverCreateCredentialRequestResult credentialRequestResult = Anoncreds.proverCreateCredentialReq(
                            wallet, objects[2].toString(), objects[3].toString(), objects[4].toString(), objects[5].toString()
                    ).get();
                    ArrayList<String> response = new ArrayList<>();
                    response.add(credentialRequestResult.getCredentialRequestJson());
                    response.add(credentialRequestResult.getCredentialRequestMetadataJson());
                    result.success(response);
                }
            } catch (Exception e) {
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class GetRevocRegDef extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[2];

            Pool pool = null;
            try {
                String request = Ledger.buildGetRevocRegDefRequest(objects[0].toString(), objects[1].toString()).get();

                pool = openPoolLedger("{}", result);
                if (pool != null) {
                    String response = Ledger.submitRequest(pool, request).get();
                    LedgerResults.ParseResponseResult credObject = Ledger.parseGetRevocRegDefResponse(response).get();
                    result.success(credObject.getObjectJson());
                }
            } catch (Exception e) {
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (pool != null) {
                    closePoolLedger(pool);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class ProverStoreCredential extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[7];

            Wallet wallet = null;
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    String newCredId;
                    if (objects[6] == null) {
                        newCredId = Anoncreds.proverStoreCredential(wallet, null, objects[3].toString(),
                                objects[4].toString(), objects[5].toString(), null).get();
                    } else {
                        newCredId = Anoncreds.proverStoreCredential(wallet, null, objects[3].toString(),
                                objects[4].toString(), objects[5].toString(), objects[6].toString()).get();
                    }
                    result.success(newCredId);
                }
            } catch (Exception e) {
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }

        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class ProverGetCredentials extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[3];
            Wallet wallet = null;
            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {
                    String credentials = Anoncreds.proverGetCredentials(wallet, objects[2].toString()).get();
                    result.success(credentials);
                }
            } catch (Exception e) {
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }

    private class ProverSearchCredentialsForProofReq extends AsyncTask {
        MethodChannel.Result result = null;

        @Override
        protected Object doInBackground(Object[] objects) {

            result = (MethodChannel.Result) objects[6];

            Wallet wallet = null;
            Pool pool = null;

            try {
                wallet = openWallet(objects[0].toString(), objects[1].toString(), result);
                if (wallet != null) {

                    pool = openPoolLedger("{}", result);

                    CredentialsSearchForProofReq credentialsSearchForProofReq = CredentialsSearchForProofReq
                            .open(wallet, objects[2].toString(), "{}").get();

                    JSONObject requestedAttributesObject = new JSONObject();
                    JSONObject predicatesAttributesObject = new JSONObject();

                    JSONObject schemas = new JSONObject();
                    JSONObject credentialDefs = new JSONObject();
                    JSONObject revocObject = new JSONObject();

                    JSONObject proofRequestObj = new JSONObject(objects[2].toString());
                    JSONObject requested_attributes = proofRequestObj.getJSONObject("requested_attributes");
                    Iterator iterator = requested_attributes.keys();

                    while (iterator.hasNext()) {
                        String key = (String) iterator.next();

                        JSONArray credentialsForAttribute = new JSONArray(
                                credentialsSearchForProofReq.fetchNextCredentials(key, 100).get());

                        if (credentialsForAttribute.length() > 0) {

                            JSONObject schemaJson = getSchemaJson(pool, objects[3].toString(), credentialsForAttribute
                                    .getJSONObject(0).getJSONObject("cred_info").getString("schema_id"));
                            schemas.put(credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                    .getString("schema_id"), schemaJson);

                            JSONObject credDefJson = getCredDefJson(pool, objects[3].toString(), credentialsForAttribute
                                    .getJSONObject(0).getJSONObject("cred_info").getString("cred_def_id"));
                            credentialDefs.put(credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                    .getString("cred_def_id"), credDefJson);

                            JSONObject object = new JSONObject();
                            object.put("cred_id", credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                    .getString("referent"));
                            object.put("revealed", true);

                            if (credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                    .getString("rev_reg_id") != "null") {
                                JSONObject revocationStateObject = createRevocationStateObject(pool,
                                        objects[3].toString(),
                                        credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                                .getString("rev_reg_id"),
                                        credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                                .getString("cred_rev_id"), (Context) objects[5]);

                                Iterator newIterator = revocationStateObject.keys();
                                Long timeStamp = Long.parseLong((String) newIterator.next());
                                object.put("timestamp", timeStamp);
                                revocObject.put(credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                        .getString("rev_reg_id"), revocationStateObject);
                            }

                            requestedAttributesObject.put(key, object);
                        }

                    }

                    JSONObject requested_predicates = proofRequestObj.getJSONObject("requested_predicates");
                    Iterator iteratorPredicates = requested_predicates.keys();

                    while (iteratorPredicates.hasNext()) {
                        String key = (String) iteratorPredicates.next();
                        JSONArray credentialsForAttribute = new JSONArray(
                                credentialsSearchForProofReq.fetchNextCredentials(key, 100).get());
                        if (credentialsForAttribute.length() > 0) {

                            JSONObject schemaJson = getSchemaJson(pool, objects[3].toString(), credentialsForAttribute
                                    .getJSONObject(0).getJSONObject("cred_info").getString("schema_id"));
                            schemas.put(credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                    .getString("schema_id"), schemaJson);

                            JSONObject credDefJson = getCredDefJson(pool, objects[3].toString(), credentialsForAttribute
                                    .getJSONObject(0).getJSONObject("cred_info").getString("cred_def_id"));
                            credentialDefs.put(credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                    .getString("cred_def_id"), credDefJson);

                            JSONObject object = new JSONObject();
                            object.put("cred_id", credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                    .getString("referent"));

                            if (credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                    .getString("rev_reg_id") != "null") {
                                JSONObject revocationStateObject = createRevocationStateObject(pool,
                                        objects[3].toString(),
                                        credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                                .getString("rev_reg_id"),
                                        credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                                .getString("cred_rev_id"), (Context) objects[5]);

                                Iterator newIterator = revocationStateObject.keys();
                                Long timeStamp = Long.parseLong((String) newIterator.next());
                                object.put("timestamp", timeStamp);
                                revocObject.put(credentialsForAttribute.getJSONObject(0).getJSONObject("cred_info")
                                        .getString("rev_reg_id"), revocationStateObject);
                            }

                            predicatesAttributesObject.put(key, object);
                        }

                    }

                    JSONObject requestedCredentials = new JSONObject();
                    JSONObject emptyObject = new JSONObject();

                    requestedCredentials.put("self_attested_attributes", emptyObject);
                    requestedCredentials.put("requested_attributes", requestedAttributesObject);
                    requestedCredentials.put("requested_predicates", predicatesAttributesObject);

                    if (requestedAttributesObject.length() == 0 && predicatesAttributesObject.length() == 0) {
                        result.error("212", "Credentials not found in your wallet", null);
                    }

                    String cred_proof = Anoncreds.proverCreateProof(wallet, objects[2].toString(),
                            String.valueOf(requestedCredentials), objects[4].toString(), String.valueOf(schemas),
                            String.valueOf(credentialDefs), String.valueOf(revocObject)).get();

                    credentialsSearchForProofReq.close();
                    result.success(cred_proof);
                }
            } catch (Exception e) {
                IndySdkRejectResponse rejectResponse = new IndySdkRejectResponse(e);
                result.error(rejectResponse.getCode(), rejectResponse.toJson(), e);
            } finally {
                if (wallet != null) {
                    closeWallet(wallet);
                }
                if (pool != null) {
                    closePoolLedger(pool);
                }
                return result;
            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
    }


    class IndySdkRejectResponse {
        private final String code;
        private final String message;

        private IndySdkRejectResponse(Throwable e) {
            String code = "0";

            if (e instanceof ExecutionException) {
                Throwable cause = e.getCause();
                if (cause instanceof IndyException) {
                    IndyException indyException = (IndyException) cause;
                    code = String.valueOf(indyException.getSdkErrorCode());
                }
            }

            String message = e.getMessage();

            this.code = code;
            this.message = message;
        }

        public String getCode() {
            return code;
        }

        public String getMessage() {
            return message;
        }

        public String toJson() {
            Gson gson = new Gson();
            return gson.toJson(this);
        }
    }
}
