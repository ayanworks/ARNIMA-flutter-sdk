/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import Flutter
import UIKit
import Indy

public class SwiftAriesFlutterMobileAgentPlugin: NSObject, FlutterPlugin {
    
    let group = DispatchGroup()
    
    let  DEFAULT_POOL_NAME = "pool"
    let PROTOCOL_VERSION = 2
    
    var schemas: [String : Any] = [:]
    var credentialDefs: [String : Any] = [:]
    var requestedAttributesObject: [String : Any] = [:]
    var requestedPredicatesObject: [String : Any] = [:]
    var revocObject: [String : Any] = [:]
    
    var objectRA: [String : Any] = [:]
    var objectPR: [String : Any] = [:]
    
    var revRegDefinationJson: String = ""
    var revRegDeltaJson: String = ""
    
    var timeStampReg: NSNumber?
    
    
    var invoked = 0
    var countRA = 0
    var countPR = 0
    var numberOfRequestedAttributes = 0
    var numberOfRequestedPredicates = 0
    var combineRequestValue = 0
    var attributeChecked = 0
    var predicateChecked = 0
    
    
    var isAttibutes: Bool = false
    var isPredicates: Bool = false
    var isCombine: Bool = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "AriesFlutterMobileAgent", binaryMessenger: registrar.messenger())
        let instance = SwiftAriesFlutterMobileAgentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let parameter = call.arguments as? [String:Any]
        
        switch call.method {
        case MethodName.createWallet:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            createWallet(config: config, credential: credential) { (status) in
                result(status)
            }
            break
        case MethodName.createStoreDid:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            let did = parameter?["didJson"] as! String
            let masterSecret = parameter?["createMasterSecret"] as! Bool
            
            createAndStoreMyDids(config: config, crential: credential, did: did, masterSecret: masterSecret) { (status) in
                result(status)
            }
            break
        case MethodName.addWalletRecord:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            let type = parameter?["type"] as! String
            let id = parameter?["id"] as! String
            let value = parameter?["value"] as! String
            let tags = parameter?["tags"] as! String
            addWalletRecord(config: config, credential: credential, type: type, id: id, value: value, tag: tags ) { (status) in
                result(status)
            }
            break
        case MethodName.createPoolLedgerConfig:
            let poolConfig = parameter?["poolConfig"] as! String
            createPoolLedgerConfig(poolConfig: poolConfig) { (status) in
                result(status)
            }
            break
            
        case MethodName.packMessage:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialsJson"] as! String
            let message = parameter?["payload"] as! String
            let receiverKeys = parameter?["recipientKeys"] as! NSArray
            let senderVerkey = parameter?["senderVk"] as! String
            
            
            let receiverKeysJson = try? JSONSerialization.data(withJSONObject: receiverKeys, options: [])
            let recipientKeys = String(data: receiverKeysJson!, encoding: .utf8)
            
            packMessage(config: config, credential: credential, message: message, receiverKeys: recipientKeys!, senderVerkey: senderVerkey)  { (status) in
                result(status)
            }
            
        case MethodName.unpackMessage:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            let message = parameter?["payload"] as! String
            
            unpackMessage(config: config, credential: credential, message: message) {  (status) in
                result(status)
            }
            break
            
        case MethodName.cryptoVerify:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            let message = parameter?["messageJson"] as! FlutterStandardTypedData
            let signVerkey = parameter?["signVerkeyJson"] as! String
            let signatureRaw = parameter?["signatureRawJson"] as! FlutterStandardTypedData
            
            let messageData = Data(message.data)
            let signatureRawData = Data(signatureRaw.data)
            
            cryptoVerify(config: config, credential: credential, signVerkey: signVerkey, message: messageData, signatureRaw: signatureRawData ) { (status) in
                result(status)
            }
            break
            
        case MethodName.proverCreateCredentialReq:
            
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            let proverDid = parameter?["proverDid"] as! String
            let credentialOfferJson = parameter?["credentialOfferJson"] as! String
            let credentialDefJson = parameter?["credentialDefJson"] as! String
            let masterSecretId = parameter?["masterSecretId"] as! String
            
            proverCreateCredentialReq(config: config, credential: credential, proverDid: proverDid, credentialOfferJson: credentialOfferJson, credentialDefJson: credentialDefJson, masterSecretId: masterSecretId) { (status) in
                result(status)
            }
            break
            
        case MethodName.getCredDef:
            let submitterDid = parameter?["submitterDid"] as! String
            let credId = parameter?["credId"] as! String
            getCredDef(submitterDid: submitterDid, credId: credId) { (status) in
                result(status)
            }
            break
            
            
        case MethodName.getRevocRegDef:
            
            let submitterDid = parameter?["submitterDid"] as! String
            let ID = parameter?["ID"] as! String
            
            getRevocRegDef(submitterDid: submitterDid, ID: ID) { (status) in
                result(status)
            }
            break
            
        case MethodName.proverStoreCredential:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            var credId: String?
            
            if let value = parameter?["credId"] as? String  {
                credId = value
            }
            
            let credReqMetadataJson = parameter?["credReqMetadataJson"] as! String
            let credJson = parameter?["credJson"] as! String
            let credDefJson = parameter?["credDefJson"] as! String
            let revRegDefJson = parameter?["revRegDefJson"] as? String
            
            
            proverStoreCredential(config: config, credential: credential, credId: credId, credReqMetadataJson: credReqMetadataJson, credJson: credJson, credDefJson: credDefJson, revRegDefJson: revRegDefJson) { (status) in
                result(status)
            }
            break
        case MethodName.proverGetCredentials:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            let filter = parameter?["filter"] as! String
            
            proverGetCredentials(configJson: config, credentialsJson: credential, filter: filter) { (status) in
                result(status)
            }
            break
            
        case MethodName.proverSearchCredentialsForProofReq:
            let config = parameter?["configJson"] as! String
            let credential = parameter?["credentialJson"] as! String
            let proofRequest = parameter?["proofRequest"] as! String
            let did = parameter?["did"] as! String
            let masterSecret = parameter?["masterSecretId"] as! String
            
            PresentProofService().proverSearchCredentialsForProofReq(config: config, credentials: credential, proofRequest: proofRequest, did: did, masterSecret: masterSecret, presentProofHandler: { status in
                result(status)
            })
            break
        default:
            result("Method is not implemented with name \(call.method)")
        }
    }
    
    
    
    private func proverCreateCredentialReq(config:String,credential:String,proverDid:String,credentialOfferJson:String,credentialDefJson:String,masterSecretId:String,handler:@escaping(_ result: Any)->()){
        
        IndyWallet().open(withConfig: config, credentials: credential) { error, IndyHandler in
            if ((error! as NSError).code > 1) {
                handler(error?.localizedDescription as Any)
            } else {
                IndyAnoncreds.proverCreateCredentialReq(forCredentialOffer: credentialOfferJson, credentialDefJSON: credentialDefJson, proverDID: proverDid, masterSecretID: masterSecretId, walletHandle: IndyHandler) { (errorPCRC, credReqJSON, credReqMetadataJSON) in
                    if ((errorPCRC! as NSError).code > 1) {
                        handler(errorPCRC?.localizedDescription as Any)
                    } else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
                            } else {
                                handler([credReqJSON,credReqMetadataJSON])
                            }
                        }
                        
                    }
                }
            }
            
        }
    }
    
    private func getCredDef(submitterDid:String,credId: String,handler:@escaping(_ result: String)->()){
        let PROTOCOL_VERSION = 2
        let DEFAULT_POOL_NAME = "pool"
        IndyPool.setProtocolVersion(PROTOCOL_VERSION as NSNumber) { (error) in
            if (error! as NSError).code > 1 {
                handler(error!.localizedDescription)
            }else{
                IndyPool.openLedger(withName: DEFAULT_POOL_NAME, poolConfig: nil) { (error, IndyHadler) in
                    if ((error! as NSError).code > 1) {
                        handler(error!.localizedDescription)
                    } else {
                        IndyLedger.buildGetCredDefRequest(withSubmitterDid: submitterDid, id: credId) { (errorBGCR, requestJSON) in
                            if ((errorBGCR! as NSError).code > 1) {
                                handler(errorBGCR!.localizedDescription)
                            } else {
                                IndyLedger.submitRequest(requestJSON, poolHandle: IndyHadler) { (errorSR, requestResultJSON) in
                                    if ((errorSR! as NSError).code > 1) {
                                        handler(errorSR!.localizedDescription)
                                    } else {
                                        IndyLedger.parseGetCredDefResponse(requestResultJSON) { (errorPGC, credDefId, credDefJson) in
                                            if ((errorPGC! as NSError).code > 1) {
                                                handler(errorPGC!.localizedDescription)
                                            } else {
                                                IndyPool.closeLedger(withHandle: IndyHadler) { (error) in
                                                    if ((error! as NSError).code > 1) {
                                                        handler(error!.localizedDescription)
                                                    } else {
                                                        if let credDefJson = credDefJson{
                                                            handler(credDefJson)
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    private func getRevocRegDef(submitterDid: String,ID: String,handler:@escaping(_ result: String)->()) {
        IndyPool.setProtocolVersion(PROTOCOL_VERSION as NSNumber) { (error) in
            if (error! as NSError).code > 1 {
                handler(error!.localizedDescription)
            }else{
                IndyPool.openLedger(withName: self.DEFAULT_POOL_NAME, poolConfig: nil) { (error, IndyHadler) in
                    if ((error! as NSError).code > 1) {
                        handler(error!.localizedDescription)
                    } else {
                        IndyLedger.buildGetRevocRegDefRequest(withSubmitterDid: submitterDid, id: ID) { (errorBGCR, requestJSON) in
                            if ((errorBGCR! as NSError).code > 1) {
                                IndyPool.closeLedger(withHandle: IndyHadler) { (closeLeaderError) in
                                    if ((closeLeaderError! as NSError).code > 1) {
                                        handler(closeLeaderError!.localizedDescription)
                                    }else {
                                        handler(errorBGCR!.localizedDescription)
                                    }
                                }
                                
                            } else {
                                IndyLedger.submitRequest(requestJSON, poolHandle: IndyHadler) { (errorSR, requestResultJSON) in
                                    if ((errorSR! as NSError).code > 1) {
                                        IndyPool.closeLedger(withHandle: IndyHadler) { (closeLeaderError) in
                                            if ((closeLeaderError! as NSError).code > 1) {
                                                handler(closeLeaderError!.localizedDescription)
                                            }else {
                                                handler(errorSR!.localizedDescription)
                                            }
                                        }
                                    } else {
                                        IndyLedger.parseGetRevocRegDefResponse(requestResultJSON) { (errorPGC, revocRegDefId, revocRegDefJson) in
                                            if ((errorPGC! as NSError).code > 1) {
                                                IndyPool.closeLedger(withHandle: IndyHadler) { (closeLeaderError) in
                                                    if ((closeLeaderError! as NSError).code > 1) {
                                                        handler(closeLeaderError!.localizedDescription)
                                                    }else {
                                                        handler(errorPGC!.localizedDescription)
                                                    }
                                                }
                                            } else {
                                                IndyPool.closeLedger(withHandle: IndyHadler) { (closeLeaderError) in
                                                    if ((closeLeaderError! as NSError).code > 1) {
                                                        handler(closeLeaderError!.localizedDescription)
                                                    }else {
                                                        handler(revocRegDefJson!)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func proverStoreCredential(config:String,credential:String,credId:String?,credReqMetadataJson:String,credJson:String,credDefJson:String,revRegDefJson:String?,handler:@escaping(_ result: String)->()){
        IndyWallet().open(withConfig: config, credentials: credential) { error, IndyHandler in
            if ((error! as NSError).code > 1) {
                handler(error!.localizedDescription)
            } else {
                IndyAnoncreds.proverStoreCredential(credJson, credID: credId, credReqMetadataJSON: credReqMetadataJson, credDefJSON: credDefJson, revRegDefJSON: revRegDefJson, walletHandle: IndyHandler) { (errorPSC, outCredID) in
                    if ((errorPSC! as NSError).code > 1) {
                        handler(errorPSC!.localizedDescription)
                    } else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError!.localizedDescription)
                            } else {
                                if let outCredID = outCredID {
                                    handler(outCredID)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func proverGetCredentials(configJson: String,credentialsJson: String,filter: String,handler:@escaping(_ result: String)->()) {
        IndyWallet().open(withConfig: configJson, credentials: credentialsJson) { error, IndyHandler in
            if ((error! as NSError).code > 1) {
                handler(error!.localizedDescription)
            } else {
                IndyAnoncreds.proverGetCredentials(forFilter: filter, walletHandle: IndyHandler) { (errorPGCF, credentialsJSON) in
                    if ((errorPGCF! as NSError).code > 1) {
                        handler(errorPGCF!.localizedDescription)
                    } else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError!.localizedDescription)
                            } else {
                                if let credentialsJSON = credentialsJSON {
                                    handler(credentialsJSON)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func createWallet(config: String, credential:String, handler: @escaping FlutterResult) {
        IndyWallet().createWallet(withConfig: config, credentials: credential) { error in
            if ((error! as NSError).code == 0 ) {
                handler("success")
            }else {
                handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
            }
        }
    }
    
    
    private func createAndStoreMyDids(config: String, crential:String, did:String,masterSecret:Bool, handler: @escaping FlutterResult) {
        IndyWallet().open(withConfig: config, credentials: crential) { error, IndyHandler in
            if ((error! as NSError).code > 1) {
                handler(error?.localizedDescription as Any)
            } else {
                print("Newely wallet open with 6 ::: \(IndyHandler)")
                IndyDid.createAndStoreMyDid(did, walletHandle: IndyHandler) { (error, did, verKey) in
                    if (error! as NSError).code > 1 {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError?.localizedDescription, details: nil))
                            } else {
                                handler(FlutterError(code: "\((error! as NSError).code)", message: error?.localizedDescription, details: nil))
                            }
                        }
                    } else {
                        if masterSecret {
                            let configlData = config.data(using: .utf8)
                            let configJson = try? JSONSerialization.jsonObject(with: configlData!, options: []) as? [String:String]
                            let id = configJson?["id"]
                            
                            IndyAnoncreds.proverCreateMasterSecret(id, walletHandle: IndyHandler) { (error, outMasterSecretId) in
                                if (error! as NSError).code == 0 {
                                    IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                                        if ((closeWalletError! as NSError).code > 1) {
                                            handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError?.localizedDescription, details: nil))
                                        } else {
                                            let resultArray = [did,verKey,outMasterSecretId]
                                            handler(resultArray)
                                        }
                                    }
                                } else {
                                    handler(FlutterError(code: "\((error! as NSError).code)", message: error?.localizedDescription, details: nil))
                                }
                            }
                            
                        } else {
                            IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                                if ((closeWalletError! as NSError).code > 1) {
                                    handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError?.localizedDescription, details: nil))
                                } else {
                                    let resultArray = [did,verKey,""]
                                    handler(resultArray)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addWalletRecord(config:String,credential:String,type:String,id:String,value:String,tag:String,handler:@escaping FlutterResult) {
        IndyWallet().open(withConfig: config, credentials: credential) { (error, IndyHandler) in
            if (error! as NSError).code > 1 {
                handler(FlutterError(code: "\((error! as NSError).code)", message: error?.localizedDescription, details: nil))
            }else {
                print("Newely wallet open with 7 ::: \(IndyHandler)")
                IndyNonSecrets.addRecord(inWallet: IndyHandler, type: type, id: id, value: value, tagsJson: tag) { (error) in
                    if (error! as NSError).code > 1 {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError?.localizedDescription, details: nil))
                            } else {
                                handler(FlutterError(code: "\((error! as NSError).code)", message: error?.localizedDescription, details: nil))
                            }
                        }
                    }else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError?.localizedDescription, details: nil))
                            } else {
                                handler(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func unpackMessage(config:String,credential:String,message:String,handler:@escaping FlutterResult) {
        IndyWallet().open(withConfig: config, credentials: credential) { (error, IndyHandler) in
            if (error! as NSError).code > 1 {
                handler(FlutterError(code: "\((error! as NSError).code)", message: error?.localizedDescription, details: nil))
            }else {
                print("Newely wallet open with 8 ::: \(IndyHandler)")
                let messageData = message.data(using: .utf8)
                IndyCrypto.unpackMessage(messageData, walletHandle: IndyHandler) { (error, resData) in
                    if (error! as NSError).code > 1 {
                        handler(FlutterError(code: "\((error! as NSError).code)", message: error?.localizedDescription, details: nil))
                    }else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError?.localizedDescription, details: nil))
                            } else {
                                let unPackMessageResult = String.init(data: resData!, encoding: .utf8)
                                if let unPackMessageResult = unPackMessageResult {
                                    handler(unPackMessageResult)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func packMessage(config:String,credential:String,message:String,receiverKeys:String,senderVerkey:String,handler:@escaping FlutterResult){
        IndyWallet().open(withConfig: config, credentials: credential) { error, IndyHandler in
            if ((error! as NSError).code > 1) {
                handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
            } else {
                print("Newely wallet open with 9 ::: \(IndyHandler)")
                IndyCrypto.createKey("{}", walletHandle: IndyHandler) { (error, verKey) in
                    if ((error! as NSError).code > 1) {
                        handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
                    } else {
                        let messageData = message.data(using: .utf8)
                        IndyCrypto.packMessage(messageData, receivers: receiverKeys, sender: senderVerkey, walletHandle: IndyHandler) { (error, packMessageData) in
                            if ((error! as NSError).code > 1) {
                                handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
                            } else {
                                IndyWallet().close(withHandle: IndyHandler) { (error) in
                                    if ((error! as NSError).code > 1) {
                                        handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
                                    } else {
                                        let packMessageResult = String.init(data: packMessageData!, encoding: .utf8)
                                        handler(packMessageResult! as String)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func cryptoVerify(config:String, credential:String, signVerkey:String, message:Data, signatureRaw:Data,  handler:@escaping FlutterResult){
        IndyWallet().open(withConfig: config, credentials: credential) { (error, IndyHandler) in
            if (error! as NSError).code > 1 {
                handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
            }else {
                print("Newely wallet open with 10 ::: \(IndyHandler)")
                IndyCrypto.verifySignature(signatureRaw, forMessage: message, key: signVerkey) { (error, isValidSignature) in
                    if (error! as NSError).code > 1 {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError!.localizedDescription, details: nil))
                            } else {
                                handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
                            }
                        }
                    }else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError!.localizedDescription, details: nil))
                            } else {
                                print("Verify Signature status: \(isValidSignature)")
                                handler(isValidSignature)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func cryptoSign(config:String,credential:String,signerKey:String,messageRaw:String,handler:@escaping FlutterResult){
        IndyWallet().open(withConfig: config, credentials: credential) { (error, IndyHandler) in
            if (error! as NSError).code > 1 {
                handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
            }else {
                print("Newely wallet open with 11 ::: \(IndyHandler)")
                let rawMessageData = messageRaw.data(using: .utf8)
                IndyCrypto.signMessage(rawMessageData, key: signerKey, walletHandle: IndyHandler) { (error, signature) in
                    if (error! as NSError).code > 1 {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError!.localizedDescription, details: nil))
                            } else {
                                handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
                            }
                        }
                    }else {
                        
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(FlutterError(code: "\((closeWalletError! as NSError).code)", message: closeWalletError!.localizedDescription, details: nil))
                            } else {
                                if let signature = signature {
                                    let bytePtr = [UInt8](signature)
                                    let length = signature.count
                                    var valueArray: [AnyHashable] = []
                                    for i in 0..<length {
                                        let someNumber = NSNumber(value: Int32(bytePtr[i]))
                                        valueArray.append(someNumber)
                                    }
                                    handler(valueArray)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}




private func getArrayOfBytesFromData(data:Data) ->[UInt8]{
    let count = data.count / MemoryLayout<UInt8>.size
    var byteArray = [UInt8](repeating: 0, count: count)
    data.copyBytes(to: &byteArray, count:count)
    return byteArray
    
}
private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

private func createPoolLedgerConfig(poolConfig:String,handler:@escaping FlutterResult) {
    let  DEFAULT_POOL_NAME = "pool"
    let PROTOCOL_VERSION = 2
    let filename = getDocumentsDirectory().appendingPathComponent("temp.txn")
    
    do {
        try poolConfig.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        handler(FlutterError(code: "", message: error.localizedDescription, details: nil))
    }
    let config = ["genesis_txn":filename.path]
    let configJson = try? JSONSerialization.data(withJSONObject: config, options: [])
    let content = String(data: configJson!, encoding: String.Encoding.utf8)
    IndyPool.setProtocolVersion(PROTOCOL_VERSION as NSNumber) { (error) in
        if (error! as NSError).code > 1 {
            handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
        }else{
            IndyPool.createPoolLedgerConfig(withPoolName: DEFAULT_POOL_NAME, poolConfig:content) { (error) in
                if (error! as NSError).code > 1 {
                    handler(FlutterError(code: "\((error! as NSError).code)", message: error!.localizedDescription, details: nil))
                }else{
                    handler(true)
                }
            }
        }
    }
}

extension Data {
    func toString() -> String {
        let newValue =  try! JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: newValue, encoding: .utf8)!
    }
}

struct MethodName {
    static let createWallet = "createWallet"
    static let createStoreDid = "createAndStoreMyDids"
    static let addWalletRecord = "addWalletRecord"
    static let unpackMessage = "unpackMessage"
    static let packMessage = "packMessage"
    static let createPoolLedgerConfig = "createPoolLedgerConfig"
    static let cryptoVerify = "cryptoVerify"
    static let cryptoSign = "cryptoSign"
    static let proverCreateCredentialReq = "proverCreateCredentialReq"
    static let proverStoreCredential = "proverStoreCredential"
    static let getCredDef = "getCredDef"
    static let getRevocRegDef = "getRevocRegDef"
    static let proverGetCredentials = "proverGetCredentials"
    static let proverSearchCredentialsForProofReq = "proverSearchCredentialsForProofReq"
}



struct ProofParameter {
    var config: String?
    var credentials: String?
    var proofRequest: String?
    var did: String?
    var masterSecret: String?
    
}

struct HandlersForproof {
    var walletHandler: IndyHandle
    var ledgerPoolHandler: IndyHandle
    var searchCredentialHandler: IndyHandle
}


struct CredentialParameter {
    var credDefIdString: String?
    var schemaIdString: String?
    var referent: String?
    var revRegId: String?
    var credRevId: String?
}



class PresentProofService {
    
    let group = DispatchGroup()
    
    let  DEFAULT_POOL_NAME = "pool"
    let PROTOCOL_VERSION = 2
    
    var schemas: [String : Any] = [:]
    var credentialDefs: [String : Any] = [:]
    var requestedAttributesObject: [String : Any] = [:]
    var requestedPredicatesObject: [String : Any] = [:]
    var revocObject: [String : Any] = [:]
    
    var objectRA: [String : Any] = [:]
    var objectPR: [String : Any] = [:]
    
    var revRegDefinationJson: String = ""
    var revRegDeltaJson: String = ""
    
    var timeStampReg: NSNumber?
    
    
    var invoked = 0
    var countRA = 0
    var countPR = 0
    var numberOfRequestedAttributes = 0
    var numberOfRequestedPredicates = 0
    var combineRequestValue = 0
    var attributeChecked = 0
    var predicateChecked = 0
    
    
    var isAttibutes: Bool = false
    var isPredicates: Bool = false
    var isCombine: Bool = false
    
    func proverSearchCredentialsForProofReq(config: String, credentials: String, proofRequest: String,did: String,masterSecret:String, presentProofHandler: @escaping FlutterResult) {
        
        let proofParameters = ProofParameter(config: config, credentials: credentials, proofRequest: proofRequest, did: did, masterSecret: masterSecret)
        
        openWalletForProof(parameter: proofParameters, indyHandler: { (walletHandler) in
            if let walletHandler = walletHandler {
                
                self.openLedgerForProof(parameter: proofParameters, indyHandler: { (generatedPoolHandle) in
                    
                    if let generatedPoolHandle = generatedPoolHandle {
                        
                        self.proverSearchCredentialsForProof(parameter: proofParameters, walletHandler: walletHandler, indyHandler: { generatedSearchHandle in
                            
                            if let generatedSearchHandle = generatedSearchHandle {
                                
                                let handlersForProof = HandlersForproof(walletHandler: walletHandler, ledgerPoolHandler: generatedPoolHandle, searchCredentialHandler: generatedSearchHandle)
                                
                                self.sendingProofResponse(parameter: proofParameters, handlersForProof: handlersForProof) { (result) in
                                    if result != "false" {
                                        presentProofHandler(result)
                                    } else {
                                        presentProofHandler(FlutterError(code: "212", message: "Requested predicate/attribute not found.", details: nil))
                                    }
                                }
                            }
                            
                        }) { (SearchCredetialError) in
                            presentProofHandler(SearchCredetialError)
                        }
                    }
                }) { (ledgerOpenError) in
                    presentProofHandler(ledgerOpenError)
                }
                
            }
        }) { (walletOpenError) in
            presentProofHandler(walletOpenError)
        }
    }
    
    private func openWalletForProof(parameter: ProofParameter,indyHandler: @escaping(_ result: IndyHandle?) -> (), handler: @escaping FlutterResult) {
        IndyWallet().open(withConfig: parameter.config, credentials: parameter.credentials) { errorOpenWallet, generatedWalletHandle in
            if (errorOpenWallet as NSError?)!.code > 1 {
                handler(FlutterError(code: "\((errorOpenWallet! as NSError).code)", message: errorOpenWallet!.localizedDescription, details: nil))
            } else {
                indyHandler(generatedWalletHandle)
            }
        }
    }
    
    
    private func openLedgerForProof(parameter: ProofParameter,indyHandler: @escaping(_ result: IndyHandle?) -> (), handler: @escaping FlutterResult){
        IndyPool.openLedger(withName: "pool", poolConfig: nil) { errorOpenLedger, generatedPoolHandle in
            if (errorOpenLedger as NSError?)!.code > 1 {
                handler(FlutterError(code: "\((errorOpenLedger! as NSError).code)", message: errorOpenLedger!.localizedDescription, details: nil))
            } else {
                indyHandler(generatedPoolHandle)
            }
        }
    }
    
    
    private func proverSearchCredentialsForProof(parameter: ProofParameter,walletHandler:IndyHandle,indyHandler: @escaping(_ result: IndyHandle?) -> (), handler: @escaping FlutterResult){
        IndyAnoncreds.proverSearchCredentials(forProofRequest: parameter.proofRequest, extraQueryJSON: nil, walletHandle: walletHandler) { errorSearchCredentialsForPR, generatedSearchHandle in
            if ((errorSearchCredentialsForPR as NSError?)?.code ?? 0) > 1 {
                handler(FlutterError(code: "\((errorSearchCredentialsForPR! as NSError).code)", message: errorSearchCredentialsForPR!.localizedDescription, details: nil))
            } else {
                indyHandler(generatedSearchHandle)
            }
        }
    }
    
    private func sendingProofResponse(parameter: ProofParameter, handlersForProof :HandlersForproof,sendingProofHandler: @escaping(_ result : String) -> ()) {
        let proofRequestEncoded = parameter.proofRequest!.data(using: .utf8)
        var proofRequestObject: NSDictionary? = nil
        do {
            if let proofRequestEncoded = proofRequestEncoded {
                proofRequestObject = try? JSONSerialization.jsonObject(with: proofRequestEncoded, options: []) as? NSDictionary
            }
        }
        
        guard let proofRequestObjectValues = proofRequestObject else {
            return
        }
        
        let requestedAttributes = proofRequestObjectValues["requested_attributes"] as? NSDictionary
        let requestedPredicates = proofRequestObjectValues["requested_predicates"] as? NSDictionary
        
        
        let requestedAttributesKeys = requestedAttributes?.allKeys
        self.numberOfRequestedAttributes = requestedAttributesKeys!.count
        
        let requestedPredicatesKeys = requestedPredicates?.allKeys
        self.numberOfRequestedPredicates = requestedPredicatesKeys!.count
        
        
        
        let requestedAttributesKeysCount = requestedAttributesKeys!.count
        let integerCountRA = requestedAttributesKeysCount
        
        if integerCountRA > 0 {
            isAttibutes = true
        }
        
        let requestedPredicatesKeysCount = requestedPredicatesKeys!.count
        let integerCountPR = requestedPredicatesKeysCount
        
        if integerCountPR > 0 {
            isPredicates = true
        }
        
        combineRequestValue = integerCountRA + integerCountPR
        
        if isAttibutes && isPredicates {
            isCombine = true
            isAttibutes = false
            isPredicates = false
            group.enter()
        }
                
        DispatchQueue.global().async {
            let semaphoreZero = DispatchSemaphore(value: 0)
            while self.countRA < integerCountRA && self.invoked < 1 {
                
                let currentKeyForAttibute = requestedAttributesKeys![self.countRA] as? String
                print("currentKeyForAttibute at \(self.countRA) ::: \(currentKeyForAttibute!)")
                var credentialsJson = ""
                
                self.proverFetchCredentialsForProof(currentKey: currentKeyForAttibute!, handlersForProof: handlersForProof) { (generatedCredentialsJson) in
                    if generatedCredentialsJson == "[]" || generatedCredentialsJson == "false" {
                        IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                            IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                                print("Requested attribute not found")
                                self.invoked = 1
                                self.countRA = integerCountRA
                                sendingProofHandler("false")
                            }
                        }
                    } else {
                        credentialsJson = generatedCredentialsJson
                        let generatedCreds = credentialsJson.data(using: .utf8)
                        var generatedCredentialsJson: [[String:Any]]? = nil
                        do {
                            if let generatedCreds = generatedCreds {
                                generatedCredentialsJson = try? JSONSerialization.jsonObject(with: generatedCreds, options: []) as? [[String : Any]]
                            }
                        }
                        
                        if (generatedCredentialsJson?[0]) != nil {
                            
                            if ((generatedCredentialsJson! as AnyObject).count ?? 0) > 0 {
                                let initialIndexObject = generatedCredentialsJson![0]["cred_info"] as! NSDictionary
                                self.withGenratedCredentialDataForAttributes(currentKey: currentKeyForAttibute!, initialIndexObject: initialIndexObject, parameterAttributes: parameter, handlersForProof: handlersForProof) { (result) in
                                    if self.isCombine {
                                        
                                        if result == "Go Next Attribute" {
                                            semaphoreZero.signal()
                                        } else {
                                            semaphoreZero.signal()
                                            self.group.leave()
                                        }
                                    } else {
                                        if result == "Go Next Attribute" {
                                            semaphoreZero.signal()
                                        } else {
                                            semaphoreZero.signal()
                                            sendingProofHandler(result)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                self.countRA += 1
                semaphoreZero.wait()
                
            }
        }
        
        group.notify(queue: .global()) {
            
            let semaphoreOne = DispatchSemaphore(value: 0)
            while self.countPR < integerCountPR && self.invoked < 1 {
                let currentKeyForPredicates = requestedPredicatesKeys![self.countPR] as? String
                print("currentKeyForPredicates at \(self.countPR) ::: \(currentKeyForPredicates!)")
                var credentialsJson = ""
                
                self.proverFetchCredentialsForProof(currentKey: currentKeyForPredicates!, handlersForProof: handlersForProof) { (generatedCredentialsJson) in
                    if generatedCredentialsJson == "[]" || generatedCredentialsJson == "false" {
                        IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                            IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                                print("Requested predicate not found")
                                self.invoked = 1
                                self.countPR = integerCountRA
                                sendingProofHandler("false")
                            }
                        }
                    } else {
                        credentialsJson = generatedCredentialsJson
                    }
                    
                    let generatedCreds = credentialsJson.data(using: .utf8)
                    var generatedCredentialsJson: [[String:Any]]? = nil
                    do {
                        if let generatedCreds = generatedCreds {
                            generatedCredentialsJson = try? JSONSerialization.jsonObject(with: generatedCreds, options: []) as? [[String : Any]]
                        }
                    }
                    
                    if let object = generatedCredentialsJson?[0] {
                        print("Genearated Cred DATA JSON \(object)")
                        
                        if ((generatedCredentialsJson! as AnyObject).count ?? 0) > 0 {
                            let initialIndexObject = generatedCredentialsJson![0]["cred_info"] as! NSDictionary
                            self.withGenratedCredentialDataForPredicates(currentKey: currentKeyForPredicates!, initialIndexObject: initialIndexObject, parameterPredicates: parameter, handlersForProof: handlersForProof){ (result) in
                                if self.isCombine {
                                    if result == "Go Next Predicate" {
                                        semaphoreOne.signal()
                                    } else {
                                        semaphoreOne.signal()
                                        sendingProofHandler(result)
                                    }
                                } else {
                                    if result == "Go Next Predicate" {
                                        semaphoreOne.signal()
                                    } else {
                                        semaphoreOne.signal()
                                        sendingProofHandler(result)
                                    }
                                }
                            }
                        }
                    }
                }
                self.countPR += 1
                semaphoreOne.wait()
            }
        }
    }
    
    private func proverFetchCredentialsForProof(currentKey: String, handlersForProof :HandlersForproof, handler: @escaping(_ result: String) -> ()){
        IndyAnoncreds.proverFetchCredentials(forProofReqItemReferent: currentKey, searchHandle: handlersForProof.searchCredentialHandler, count: NSNumber(value: 1)) { (errorfetchCredItemReferent, generatedCredentialsJson) in
            if ((errorfetchCredItemReferent as NSError?)?.code ?? 0) > 1 {
                print("Error/ Success in fetch Cred for Item Referent \(errorfetchCredItemReferent!)")
                handler("false")
            } else {
                if let generatedCredentialsJson = generatedCredentialsJson{
                    handler(generatedCredentialsJson)
                }
            }
        }
    }
    
    
    private  func withGenratedCredentialDataForAttributes(currentKey: String, initialIndexObject: NSDictionary,parameterAttributes: ProofParameter, handlersForProof :HandlersForproof,attributesResponseHandler: @escaping(_ result : String) -> ()) {
        let credDefIdString = initialIndexObject["cred_def_id"] as? String
        let schemaIdString = initialIndexObject["schema_id"] as? String
        let referent = initialIndexObject["referent"] as? String
        let revRegId = initialIndexObject["rev_reg_id"] as? String
        let credRevId = initialIndexObject["cred_rev_id"] as? String
        
        let credParameter = CredentialParameter(credDefIdString: credDefIdString, schemaIdString: schemaIdString, referent: referent, revRegId: revRegId, credRevId: credRevId)
        
        self.createRequestSchema(credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
            
            
            self.createRequestSchemaResult(requestJSONSchema: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                
                self.initSchema(requestResultJSONSchema: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                                        
                    self.initCredDef(credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (generatedRequestJSON) in
                        
                        self.initSubmitCredDefRequest(requestJSONCred: generatedRequestJSON, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                            
                            
                            
                            self.initParseGetCredDefRequestForAttributes(requestResultJSONCred: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                                
                                if credParameter.revRegId != nil {
                                    self.initBuildRevRegDelta(credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                                        
                                        self.initSubmitRevRegDeltaRequest(requestJSONRevDelta: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                                            
                                            self.initParseRevRegDelta(requestResultJSONRevDelta: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (revocRegDeltaJSON) in
                                                
                                                
                                                self.initBuildGetRevRegDef(credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                                                    
                                                    self.submitRevRegDef(requestJSONRevDef: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                                                        
                                                        self.parseRevRegDef(requestResultJSONRevDef: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (parseRevRegResponse) in
                                                            if parseRevRegResponse != "false" {
                                                                self.initStorageHandler(tailsWriterConfigString: parseRevRegResponse, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes, handler: { (result) in
                                                                    attributesResponseHandler(result)
                                                                }) { (number) in
                                                                    
                                                                    self.initRevocationState(storageHandle: number, timeStamp: self.timeStampReg!, revRegDefJSON: generatedRequestJSON, revocRegDeltaJSON: revocRegDeltaJSON, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterAttributes) { (result) in
                                                                        
                                                                        if !result.isEmpty {
                                                                    
                                                                            self.requestedAttributesObject[currentKey] = self.objectRA
                                                                            self.attributeChecked = self.requestedAttributesObject.count
                                                                            
                                                                            if self.isCombine {
                                                                                
                                                                                if self.numberOfRequestedAttributes == self.attributeChecked {
                                                                                    attributesResponseHandler(result)
                                                                                }else {
                                                                                   attributesResponseHandler("Go Next Attribute")
                                                                                }
                                                                                
                                                                            } else if self.isAttibutes {
                                                                                
                                                                                if self.numberOfRequestedAttributes == self.attributeChecked {
                                                                                    self.isAttibutes = false
                                                                                    print("Current Attribute number ::: \(self.attributeChecked)")
                                                                                                                                                                self.proof(parameter: parameterAttributes, handlersForProof: handlersForProof) { (result) in
                                                                                        attributesResponseHandler(result)
                                                                                    }
                                                                                } else {
                                                                                     attributesResponseHandler("Go Next Attribute")
                                                                                }
                                                                            } else {
                                                                                print("No choice.....")
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            } else {
                                                                attributesResponseHandler(parseRevRegResponse)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    self.requestedAttributesObject[currentKey] = self.objectRA
                                    
                                    self.attributeChecked = self.requestedAttributesObject.count
                                    
                                    if self.isCombine {
                                        
                                        if self.numberOfRequestedAttributes == self.attributeChecked {
                                            attributesResponseHandler(result)
                                        } else {
                                            attributesResponseHandler("Go Next Attribute")
                                        }
                                        
                                    } else if self.isAttibutes {
                                        
                                        if self.numberOfRequestedAttributes == self.attributeChecked {
                                            self.isAttibutes = false
                                            print("numberOfRequestedAttributes ::: \(self.countRA)")
                                            print("Current Attribute number ::: \(self.attributeChecked)")
                                            
                                            self.proof(parameter: parameterAttributes, handlersForProof: handlersForProof) { (result) in
                                                attributesResponseHandler(result)
                                            }
                                        } else {
                                            attributesResponseHandler("Go Next Attribute")
                                        }
                                    } else {
                                        print("No choice")
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    
                }
                
            }
        }
    }
    
    private  func withGenratedCredentialDataForPredicates(currentKey: String, initialIndexObject: NSDictionary,parameterPredicates: ProofParameter, handlersForProof :HandlersForproof,predicatesResponseHandler: @escaping(_ result : String) -> ()) {
        let credDefIdString = initialIndexObject["cred_def_id"] as? String
        let schemaIdString = initialIndexObject["schema_id"] as? String
        let referent = initialIndexObject["referent"] as? String
        let revRegId = initialIndexObject["rev_reg_id"] as? String
        let credRevId = initialIndexObject["cred_rev_id"] as? String
        
        let credParameter = CredentialParameter(credDefIdString: credDefIdString, schemaIdString: schemaIdString, referent: referent, revRegId: revRegId, credRevId: credRevId)
        
        self.createRequestSchema(credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
            
            
            self.createRequestSchemaResult(requestJSONSchema: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                
                self.initSchema(requestResultJSONSchema: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                    
                    
                    self.initCredDef(credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (generatedRequestJSON) in
                        
                        self.initSubmitCredDefRequest(requestJSONCred: generatedRequestJSON, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                            
                            self.initParseGetCredDefRequestForPredicates(requestResultJSONCred: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                                
                                if credParameter.revRegId != nil {
                                    self.initBuildRevRegDelta(credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                                        
                                        self.initSubmitRevRegDeltaRequest(requestJSONRevDelta: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                                            
                                            self.initParseRevRegDelta(requestResultJSONRevDelta: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (revocRegDeltaJSON) in
                                                self.initBuildGetRevRegDef(credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                                                    
                                                    self.submitRevRegDef(requestJSONRevDef: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                                                        self.parseRevRegDef(requestResultJSONRevDef: result, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (parseRevRegResponse) in
                                                            
                                                            if parseRevRegResponse != "false" {
                                                                self.initStorageHandler(tailsWriterConfigString: parseRevRegResponse, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates, handler: { (result) in
                                                                    predicatesResponseHandler(result)
                                                                }) { (number) in
                                                                    
                                                                    self.initRevocationState(storageHandle: number, timeStamp: self.timeStampReg!, revRegDefJSON: generatedRequestJSON, revocRegDeltaJSON: revocRegDeltaJSON, credParameters: credParameter, handlersForProof: handlersForProof, parameter: parameterPredicates) { (result) in
                                                                        
                                                                        if !result.isEmpty {
                                                                            print("Count PR ::: \(self.countPR)")
                                                                            self.requestedPredicatesObject[currentKey] = self.objectPR
                                                                            self.predicateChecked = self.requestedPredicatesObject.count
                                                                            
                                                                            if self.isCombine {
                                                                                if self.numberOfRequestedAttributes == self.attributeChecked && self.numberOfRequestedPredicates == self.predicateChecked {
                                                                                    self.proof(parameter: parameterPredicates, handlersForProof: handlersForProof) { (result) in
                                                                                        predicatesResponseHandler(result)
                                                                                    }
                                                                                }
                                                                                
                                                                            }else if self.isPredicates {
                                                                                if self.numberOfRequestedPredicates == self.predicateChecked {
                                                                                    self.isPredicates = false
                                                                                    print("numberOfRequestedAttributes ::: \(self.countRA)")
                                                                                    print("Current Predicate number ::: \(self.predicateChecked)")
                                                                                    
                                                                                    self.proof(parameter: parameterPredicates, handlersForProof: handlersForProof) { (result) in
                                                                                        predicatesResponseHandler(result)
                                                                                    }
                                                                                } else {
                                                                                    print("I in else Here Predicates")
                                                                                    predicatesResponseHandler("Go Next Predicate")
                                                                                }
                                                                            }
                                                                        }
                                                                        
                                                                    }
                                                                }
                                                            } else {
                                                                predicatesResponseHandler(parseRevRegResponse)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    self.requestedPredicatesObject[currentKey] = self.objectPR
                                    self.predicateChecked = self.requestedPredicatesObject.count
                                    
                                    if self.isCombine {
                                        if self.numberOfRequestedAttributes == self.attributeChecked && self.numberOfRequestedPredicates == self.predicateChecked {
                                            self.proof(parameter: parameterPredicates, handlersForProof: handlersForProof) { (result) in
                                                predicatesResponseHandler(result)
                                            }
                                        } else {
                                            print("I in else Here Predicates")
                                            predicatesResponseHandler("Go Next Predicate")
                                        }
                                        
                                    }else if self.isPredicates {
                                        if self.numberOfRequestedPredicates == self.predicateChecked {
                                            self.isPredicates = false
                                            print("numberOfRequestedAttributes ::: \(self.countRA)")
                                            print("Current Predicate number ::: \(self.predicateChecked)")
                                            
                                            self.proof(parameter: parameterPredicates, handlersForProof: handlersForProof) { (result) in
                                                predicatesResponseHandler(result)
                                            }
                                        }else {
                                            print("I in else Here Predicates")
                                            predicatesResponseHandler("Go Next Predicate")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
            }
        }
    }
    
    private func createRequestSchema(credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var requestJSONSchema = ""
        IndyLedger.buildGetSchemaRequest(withSubmitterDid: parameter.did, id: credParameters.schemaIdString) { errorBuildGetSchemaRequest, generatedRequestJSON in
            if ((errorBuildGetSchemaRequest as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorBuildGetSchemaRequest = errorBuildGetSchemaRequest {
                            print("Build Get schema Request ERROR \(errorBuildGetSchemaRequest)")
                        }
                        handler(errorBuildGetSchemaRequest!.localizedDescription)
                    }
                }
            } else {
                requestJSONSchema = generatedRequestJSON ?? ""
                handler(requestJSONSchema)
            }
        }
    }
    private func createRequestSchemaResult(requestJSONSchema: String, credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var requestResultJSONSchema = ""
        IndyLedger.submitRequest(requestJSONSchema, poolHandle: handlersForProof.ledgerPoolHandler) { errorSubmitRequest, generatedRequestResultJSON in
            if ((errorSubmitRequest as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorSubmitRequest = errorSubmitRequest {
                            print("Submit Request schema Request ERROR \(errorSubmitRequest)")
                        }
                        handler(errorSubmitRequest!.localizedDescription)
                    }
                }
            } else {
                requestResultJSONSchema = generatedRequestResultJSON ?? ""
                handler(requestResultJSONSchema)
            }
        }
        
    }
    
    
    private func initSchema(requestResultJSONSchema: String, credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var schemaJSON = ""
        IndyLedger.parseGetSchemaResponse(requestResultJSONSchema) { errorParseSchemaResponse, schemaId, generatedSchemaJson in
            if ((errorParseSchemaResponse as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorParseSchemaResponse = errorParseSchemaResponse {
                            print("Parse Schema Response ERROR \(errorParseSchemaResponse)")
                        }
                        handler(errorParseSchemaResponse!.localizedDescription)
                    }
                }
            } else {
                schemaJSON = generatedSchemaJson ?? ""
                let schemaJsonGenData = schemaJSON.data(using: .utf8)
                var generatedSchemaJSONObject: Any? = nil
                do {
                    if let schemaJsonGenData = schemaJsonGenData {
                        generatedSchemaJSONObject = try? JSONSerialization.jsonObject(with: schemaJsonGenData, options: [])
                    }
                }
                self.schemas[credParameters.schemaIdString!] = generatedSchemaJSONObject
                handler(schemaJSON)
            }
        }
        
        
    }
    
    private func initCredDef(credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var requestJSONCred = ""
        IndyLedger.buildGetCredDefRequest(withSubmitterDid: parameter.did, id: credParameters.credDefIdString) { errorBuildGetCredDef, generatedRequestJSON in
            if ((errorBuildGetCredDef as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorBuildGetCredDef = errorBuildGetCredDef {
                            print("Build Cred Def ERROR \(errorBuildGetCredDef)")
                        }
                        handler(errorBuildGetCredDef!.localizedDescription)
                    }
                }
            } else {
                requestJSONCred = generatedRequestJSON ?? ""
                handler(requestJSONCred)
            }
        }
        
    }
    
    private func initSubmitCredDefRequest(requestJSONCred: String, credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var requestResultJSONCred = ""
        IndyLedger.submitRequest(requestJSONCred, poolHandle: handlersForProof.ledgerPoolHandler) { errorSubmitRequest, generatedRequestResultJSON in
            if ((errorSubmitRequest as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorSubmitRequest = errorSubmitRequest {
                            print("Submit Cred request ERROR \(errorSubmitRequest)")
                        }
                        handler(errorSubmitRequest!.localizedDescription)
                    }
                }
            } else {
                requestResultJSONCred = generatedRequestResultJSON ?? ""
                handler(requestResultJSONCred)
            }
        }
        
    }
    
    private func initParseGetCredDefRequestForAttributes(requestResultJSONCred: String, credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var credDefJSON = ""
        IndyLedger.parseGetCredDefResponse(requestResultJSONCred) { errorParseCredDef, credDefId, generatedCredDefJson in
            if ((errorParseCredDef as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorParseCredDef = errorParseCredDef {
                            print("Parse Get Cred Def ERROR \(errorParseCredDef)")
                        }
                        handler(errorParseCredDef!.localizedDescription)
                    }
                }
            } else {
                credDefJSON = generatedCredDefJson ?? ""
                let credDefJsonGenData = credDefJSON.data(using: .utf8)
                var generatedCredDefJSONObject: Any? = nil
                do {
                    if let credDefJsonGenData = credDefJsonGenData {
                        generatedCredDefJSONObject = try? JSONSerialization.jsonObject(with: credDefJsonGenData, options: [])
                    }
                }
                self.credentialDefs[credParameters.credDefIdString!] = generatedCredDefJSONObject
                                
                self.objectRA.removeAll()
                
                self.objectRA["cred_id"] = credParameters.referent
                self.objectRA["revealed"] = true
                
                handler(credDefJSON)
                
            }
        }
    }
    
    
    private func initParseGetCredDefRequestForPredicates(requestResultJSONCred: String, credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var credDefJSON = ""
        IndyLedger.parseGetCredDefResponse(requestResultJSONCred) { errorParseCredDef, credDefId, generatedCredDefJson in
            if ((errorParseCredDef as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorParseCredDef = errorParseCredDef {
                            print("Parse Get Cred Def ERROR \(errorParseCredDef)")
                        }
                        handler(errorParseCredDef!.localizedDescription)
                    }
                }
            } else {
                credDefJSON = generatedCredDefJson ?? ""
                let credDefJsonGenData = credDefJSON.data(using: .utf8)
                var generatedCredDefJSONObject: Any? = nil
                do {
                    if let credDefJsonGenData = credDefJsonGenData {
                        generatedCredDefJSONObject = try? JSONSerialization.jsonObject(with: credDefJsonGenData, options: [])
                    }
                }
                self.credentialDefs[credParameters.credDefIdString!] = generatedCredDefJSONObject
                                
                self.objectPR.removeAll()
                self.objectPR["cred_id"] = credParameters.referent
                self.objectPR["revealed"] = true
                handler(credDefJSON)
                
            }
        }
    }
    
    
    private func initBuildRevRegDelta(credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        if let revRegId = credParameters.revRegId {
            let timeStampDouble = Date().timeIntervalSince1970
            let timeStampNumber = NSNumber(value: Int32(timeStampDouble))
            
            var requestJSONRevDelta = ""
            IndyLedger.buildGetRevocRegDeltaRequest(withSubmitterDid: parameter.did, revocRegDefId: revRegId, from: NSNumber(value: 0), to: timeStampNumber) { errorBuildGetRevReg, generatedRequestJSON in
                if ((errorBuildGetRevReg as NSError?)?.code ?? 0) > 1 {
                    IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                        IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                            if let errorBuildGetRevReg = errorBuildGetRevReg {
                                print("Build Get Rev Reg Delta ERROR \(errorBuildGetRevReg)")
                            }
                            handler(errorBuildGetRevReg!.localizedDescription)
                        }
                    }
                } else {
                    requestJSONRevDelta = generatedRequestJSON ?? ""
                    handler(requestJSONRevDelta)
                }
            }
        } else {
            print("initRevRegId : revRegId -> No Value: initBuildRevRegDelta")
            handler("{}")
        }
    }
    
    
    private func initSubmitRevRegDeltaRequest( requestJSONRevDelta: String,credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var requestResultJSONRevDelta = ""
        IndyLedger.submitRequest(requestJSONRevDelta, poolHandle: handlersForProof.ledgerPoolHandler) { errorSubmitRevRegDeltaRequest, generatedRequestResultJSON in
            if ((errorSubmitRevRegDeltaRequest as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorSubmitRevRegDeltaRequest = errorSubmitRevRegDeltaRequest {
                            print("Submit Rev Reg Delta Request ERROR \(errorSubmitRevRegDeltaRequest)")
                        }
                        handler(errorSubmitRevRegDeltaRequest!.localizedDescription)
                    }
                }
            } else {
                requestResultJSONRevDelta = generatedRequestResultJSON ?? ""
                handler(requestResultJSONRevDelta)
            }
        }
        
    }
    
    private func initParseRevRegDelta( requestResultJSONRevDelta: String,credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()){
        var revocRegDeltaJSON = ""
        var timeStamp = NSNumber()
        IndyLedger.parseGetRevocRegDeltaResponse(requestResultJSONRevDelta) { errorParseRev, revocRegDefId, generatedRevocRegDeltaJson, generatedTimestamp in
            if ((errorParseRev as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorParseRev = errorParseRev {
                            print("Parse Revoc Reg Delta ERROR \(errorParseRev)")
                        }
                        handler(errorParseRev!.localizedDescription)
                    }
                }
            } else {
                if let generatedTimestamp = generatedTimestamp {
                    timeStamp = generatedTimestamp
                    self.timeStampReg = timeStamp
                }
                if let generatedRevocRegDeltaJson = generatedRevocRegDeltaJson {
                    revocRegDeltaJSON = generatedRevocRegDeltaJson
                    self.revRegDeltaJson = revocRegDeltaJSON
                    handler(generatedRevocRegDeltaJson)
                }
                
            }
        }
        
    }
    
    private func initBuildGetRevRegDef(credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()) {
        var requestJSONRevDef = ""
        IndyLedger.buildGetRevocRegDefRequest(withSubmitterDid: parameter.did, id: credParameters.revRegId) { errorBuildGetRevRegDef, generatedRequestJSON in
            if ((errorBuildGetRevRegDef as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorBuildGetRevRegDef = errorBuildGetRevRegDef {
                            print("Build Get Rev Reg Def ERROR \(errorBuildGetRevRegDef)")
                        }
                        handler(errorBuildGetRevRegDef!.localizedDescription)
                    }
                }
            } else {
                requestJSONRevDef = generatedRequestJSON ?? ""
                handler(requestJSONRevDef)
            }
        }
    }
    
    private func submitRevRegDef(requestJSONRevDef: String,credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()) {
        var requestResultJSONRevDef = ""
        IndyLedger.submitRequest(requestJSONRevDef, poolHandle: handlersForProof.ledgerPoolHandler) { errorSubmitRevDef, generatedRequestResultJSON in
            if ((errorSubmitRevDef as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorSubmitRevDef = errorSubmitRevDef {
                            print("Submit Rev Def ERROR \(errorSubmitRevDef)")
                        }
                        handler(errorSubmitRevDef!.localizedDescription)
                    }
                }
            } else {
                requestResultJSONRevDef = generatedRequestResultJSON ?? ""
                handler(requestResultJSONRevDef)
            }
        }
        
    }
    
    private func parseRevRegDef(requestResultJSONRevDef: String,credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()) {
        var revocRegDefJSON = ""
        IndyLedger.parseGetRevocRegDefResponse(requestResultJSONRevDef) { errorParseRevDef, revocRegDefId, generatedRevocRegDefJson in
            if ((errorParseRevDef as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorParseRevDef = errorParseRevDef {
                            print("Parse Rev Reg Def ERROR \(errorParseRevDef)")
                        }
                        handler("false")
                    }
                }
            } else {
                revocRegDefJSON = generatedRevocRegDefJson ?? ""
                self.revRegDefinationJson = revocRegDefJSON
                
                let revocRegDefJsonData = revocRegDefJSON.data(using: .utf8)
                var generatedRevocRegDefJsonData: Any? = nil
                do {
                    if let revocRegDefJsonData = revocRegDefJsonData {
                        generatedRevocRegDefJsonData = try? JSONSerialization.jsonObject(with: revocRegDefJsonData, options: [])
                    }
                }
                var tailsHash = String()
                tailsHash = ((generatedRevocRegDefJsonData! as AnyObject).value(forKeyPath: "value.tailsHash") as? String)!
                var tailsFileLocation: String = String()
                tailsFileLocation = ((generatedRevocRegDefJsonData! as AnyObject).value(forKeyPath: "value.tailsLocation") as? String)!
                print("Revoc RegDef tailsFileLocation \(tailsFileLocation)")
                
                let tailsFileLocationPath = tailsFileLocation.removingPercentEncoding!.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
                
                var url: URL?
                
                if let tailsFileLocationPath = tailsFileLocationPath {
                    url = URL(string: tailsFileLocationPath)
                } else {
                    print("Issue with tails file path.")
                    handler("false")
                }
                var urlData: Data? = nil
                
                if let url = url {
                    urlData = try? Data(contentsOf: url)
                } else {
                    print("Issue with tails file url.")
                    handler("false")
                }
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
                let documentsDirectory = paths[0]
                let dataPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("revoc").path
                
                if (urlData != nil) {
                    if !FileManager.default.fileExists(atPath: dataPath) {
                        do {
                            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
                        } catch {
                        }
                    }
                    let filePath = "\(dataPath)/\(tailsHash)"
                    do {
                        try urlData?.write(to: URL(fileURLWithPath: filePath))
                        
                    }catch let error {
                        print("error \(error)")
                    }
                    
                    
                    var pathOfTailsFile = "\(dataPath)/"
                    pathOfTailsFile = URL(fileURLWithPath: pathOfTailsFile).standardized.path
                    print("TailsFile Path \(pathOfTailsFile)")
                    var tailsWriterConfig: [AnyHashable : Any] = [:]
                    tailsWriterConfig["base_dir"] = pathOfTailsFile
                    tailsWriterConfig["uri_pattern"] = ""
                    
                    var tailsWriterConfigData: Data? = nil
                    do {
                        tailsWriterConfigData = try? JSONSerialization.data(withJSONObject: tailsWriterConfig, options: .prettyPrinted)
                    }
                    var tailsWriterConfigString: String? = nil
                    if let tailsWriterConfigData = tailsWriterConfigData {
                        tailsWriterConfigString = String(data: tailsWriterConfigData, encoding: .utf8)
                        if let tailsWriterConfigString = tailsWriterConfigString{
                            handler(tailsWriterConfigString)
                        }
                    }
                } else {
                    print("Issue with tails file.")
                    handler("false")
                }
            }
        }
    }
    
    private func initStorageHandler(tailsWriterConfigString: String,credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> (),storageHandler:@escaping(_ result : NSNumber) -> ()) {
        var storageHandle = NSNumber()
        IndyBlobStorage.openReader(withType: "default", config: tailsWriterConfigString) { errorOpenReader, handle in
            if ((errorOpenReader as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorOpenReader = errorOpenReader {
                            print("Blob Open Reader ERROR \(errorOpenReader)")
                        }
                        handler(errorOpenReader!.localizedDescription)
                    }
                }
            } else {
                if let handle = handle {
                    storageHandle = handle
                    storageHandler(storageHandle)
                }
                
            }
        }
        
    }
    
    private func initRevocationState(storageHandle: NSNumber,timeStamp: NSNumber,revRegDefJSON: String, revocRegDeltaJSON: String, credParameters: CredentialParameter,handlersForProof :HandlersForproof,parameter: ProofParameter,handler: @escaping(_ result : String) -> ()) {
        var revStateJSON = ""
        IndyAnoncreds.createRevocationState(forCredRevID: credParameters.credRevId, timestamp: timeStamp, revRegDefJSON: self.revRegDefinationJson, revRegDeltaJSON: self.revRegDeltaJson, blobStorageReaderHandle: storageHandle) { errorRevState, generatedRevStateJSON in
            if ((errorRevState as NSError?)?.code ?? 0) > 1 {
                IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                        if let errorRevState = errorRevState {
                            print("Rev State ERROR \(errorRevState)")
                        }
                        handler(errorRevState!.localizedDescription)
                    }
                }
            } else {
                revStateJSON = generatedRevStateJSON ?? ""
                
                let revocStateJsonData = revStateJSON.data(using: .utf8)
                var revocStateJsonDataObject: Any? = nil
                do {
                    if let revocStateJsonData = revocStateJsonData {
                        revocStateJsonDataObject = try JSONSerialization.jsonObject(with: revocStateJsonData, options: [])
                    }
                } catch {
                }
                
                var newObject: [AnyHashable : Any] = [:]
                let timeStampString = "\(timeStamp)"
                
                newObject[timeStampString] = revocStateJsonDataObject
                
                self.objectRA["timestamp"] = timeStamp
                self.objectPR["timestamp"] = timeStamp
                
                self.revocObject[credParameters.revRegId!] = newObject
                
                handler(revStateJSON)
            }
        }
        
    }
    
    
    private func proof(parameter: ProofParameter, handlersForProof :HandlersForproof,handler: @escaping(_ result : String) -> ()) {
        var requestedCredentials: [String : Any] = [:]
        requestedCredentials["self_attested_attributes"] = [:]
        requestedCredentials["requested_attributes"] = requestedAttributesObject
        requestedCredentials["requested_predicates"] = requestedPredicatesObject
        
        if requestedPredicatesObject.count < 1 && requestedAttributesObject.count < 1 && invoked < 1 {
            IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                    print("Requested attribute/predicate not found")
                    handler("false")
                }
            }
        }
        
        var requestedCredentialsData: Data? = nil
        do {
            requestedCredentialsData = try? JSONSerialization.data(
                withJSONObject: requestedCredentials,
                options: .prettyPrinted)
        }
        var requestedCredentialsJSON: String? = nil
        if let requestedCredentialsData = requestedCredentialsData {
            requestedCredentialsJSON = String(data: requestedCredentialsData, encoding: .utf8)
        }
        
        var schemasData: Data? = nil
        do {
            schemasData = try? JSONSerialization.data(
                withJSONObject: schemas,
                options: .prettyPrinted)
        }
        var schemasJson: String? = nil
        if let schemasData = schemasData {
            schemasJson = String(data: schemasData, encoding: .utf8)
        }
        
        var credentialDefsData: Data? = nil
        do {
            credentialDefsData = try? JSONSerialization.data(
                withJSONObject: credentialDefs,
                options: .prettyPrinted)
        }
        var credentialDefsJson: String? = nil
        if let credentialDefsData = credentialDefsData {
            credentialDefsJson = String(data: credentialDefsData, encoding: .utf8)
        }
        
        var revocObjectData: Data? = nil
        do {
            revocObjectData = try? JSONSerialization.data(
                withJSONObject: revocObject,
                options: .prettyPrinted)
        }
        var revocObjectDataString: String? = nil
        if let revocObjectData = revocObjectData {
            revocObjectDataString = String(data: revocObjectData, encoding: .utf8)
        }
        
        if invoked < 1 {
            IndyAnoncreds.proverCreateProof(forRequest: parameter.proofRequest!,
                                            requestedCredentialsJSON: requestedCredentialsJSON!,
                                            masterSecretID: parameter.masterSecret,
                                            schemasJSON: schemasJson!,
                                            credentialDefsJSON: credentialDefsJson!,
                                            revocStatesJSON: revocObjectDataString!,
                                            walletHandle: handlersForProof.walletHandler) { (errorPR, proofJSON) in
                                                if (errorPR! as NSError).code > 1 {
                                                    IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                                                        IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                                                            print("Proof Req ERROR \(errorPR!)")
                                                            handler("false")
                                                        }
                                                    }
                                                } else {
                                                    IndyPool.closeLedger(withHandle: handlersForProof.ledgerPoolHandler) { error in
                                                        IndyWallet().close(withHandle: handlersForProof.walletHandler) { error in
                                                            if let proofJSON = proofJSON {
                                                                self.requestedAttributesObject.removeAll()
                                                                self.requestedPredicatesObject.removeAll()
                                                                handler(proofJSON)
                                                            }
                                                        }
                                                    }
                                                }
            }
        } else {
            handler("false")
        }
    }
}
