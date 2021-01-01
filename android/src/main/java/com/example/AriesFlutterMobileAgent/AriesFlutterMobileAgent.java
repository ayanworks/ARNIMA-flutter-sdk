package com.example.AriesFlutterMobileAgent;

import android.os.AsyncTask;
import android.util.Log;
import android.os.Environment;

import com.google.gson.Gson;

import org.hyperledger.indy.sdk.IndyException;
import org.hyperledger.indy.sdk.anoncreds.Anoncreds;
import org.hyperledger.indy.sdk.crypto.Crypto;
import org.hyperledger.indy.sdk.did.Did;
import org.hyperledger.indy.sdk.did.DidResults;
import org.hyperledger.indy.sdk.non_secrets.WalletRecord;
import org.hyperledger.indy.sdk.pool.Pool;
import org.hyperledger.indy.sdk.pool.PoolJSONParameters;
import org.hyperledger.indy.sdk.wallet.Wallet;
import org.json.JSONObject;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.concurrent.ExecutionException;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class AriesFlutterMobileAgent extends FlutterActivity {

    private static final String DEFAULT_POOL_NAME = "pool";
    public static final int PROTOCOL_VERSION = 2;

    public void createPoolLedgerConfig(String poolConfig, MethodChannel.Result result) {
        new CreatePoolLedgerConfig().execute(poolConfig, result);
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

    public void createWallet(String configJson, String credentialsJson, MethodChannel.Result result) {
        new CreateWallet().execute(configJson, credentialsJson, result);
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

    public void addWalletRecord(String configJson, String credentialsJson, String type, String id, String value, String tags,
                                MethodChannel.Result result) {
        new AddWalletRecord().execute(configJson, credentialsJson, type, id, value, tags, result);
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

    public void packMessage(String configJson, String credentialsJson, byte[] message,
                            ArrayList<String> receiverKeys, String senderVk, MethodChannel.Result result) {
        new PackMessage().execute(configJson, credentialsJson, message, receiverKeys, senderVk, result);
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

    public void unpackMessage(String configJson, String credentialsJson, byte[] jwe, MethodChannel.Result result) {
        new UnpackMessage().execute(configJson, credentialsJson, jwe, result);
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

    public void cryptoSign(String configJson, String credentialsJson, String signerVk, byte[] messageRaw,
                           MethodChannel.Result result) {
        new cryptoSign().execute(configJson, credentialsJson, signerVk, messageRaw, result);
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


    public void cryptoVerify(String configJson, String credentialsJson, String signerVk, byte[] messageRaw,
                             byte[] signatureRaw, MethodChannel.Result result) {
        new CryptoVerify().execute(configJson, credentialsJson, signerVk, messageRaw, signatureRaw, result);
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

    class IndySdkRejectResponse {
        private String code;
        private String message;

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
