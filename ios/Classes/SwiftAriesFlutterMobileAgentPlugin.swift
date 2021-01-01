import Flutter
import UIKit
import Indy

public class SwiftAriesFlutterMobileAgentPlugin: NSObject, FlutterPlugin {
    
    
    
    
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
        default:
            result("Method is not implemented with name \(call.method)")
        }
        
        
        
        
        
    }
    
    //MARK: - Native functions
    
    private func createWallet(config: String, credential:String, handler: @escaping(_ walletStatus: String)->()) {
        IndyWallet().createWallet(withConfig: config, credentials: credential) { error in
            if ((error! as NSError).code == 0 ) {
                handler("success")
            }else {
                handler(error!.localizedDescription)
            }
        }
    }
    
    
    private func createAndStoreMyDids(config: String, crential:String, did:String,masterSecret:Bool, handler: @escaping(_ result: Any)->()) {
        IndyWallet().open(withConfig: config, credentials: crential) { error, IndyHandler in
            if ((error! as NSError).code > 1) {
                handler(error?.localizedDescription as Any)
            } else {
                IndyDid.createAndStoreMyDid(did, walletHandle: IndyHandler) { (error, did, verKey) in
                    if (error! as NSError).code > 1 {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
                            } else {
                                handler(error?.localizedDescription as Any)
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
                                            handler(closeWalletError?.localizedDescription as Any)
                                        } else {
                                            let resultArray = [did,verKey,outMasterSecretId]
                                            handler(resultArray)
                                        }
                                    }
                                } else {
                                    handler(error?.localizedDescription as Any)
                                }
                            }
                            
                        } else {
                            
                            IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                                if ((closeWalletError! as NSError).code > 1) {
                                    handler(closeWalletError?.localizedDescription as Any)
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
    
    
    
    private func addWalletRecord(config:String,credential:String,type:String,id:String,value:String,tag:String,handler:@escaping(_ result :Any)->()) {
        IndyWallet().open(withConfig: config, credentials: credential) { (error, IndyHandler) in
            if (error! as NSError).code > 1 {
                handler("Error in function: \(#function):at line:\(error.debugDescription)")
            }else {
                IndyNonSecrets.addRecord(inWallet: IndyHandler, type: type, id: id, value: value, tagsJson: tag) { (error) in
                    if (error! as NSError).code > 1 {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
                            } else {
                                handler(error?.localizedDescription as Any)
                            }
                        }
                    }else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
                            } else {
                                handler(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func unpackMessage(config:String,credential:String,message:String,handler:@escaping(_ result:Any)->()) {
        IndyWallet().open(withConfig: config, credentials: credential) { (error, IndyHandler) in
            if (error! as NSError).code > 1 {
                handler("Error in function: \(#function):at line:\(error.debugDescription)")
            }else {
                let messageData = message.data(using: .utf8)
                IndyCrypto.unpackMessage(messageData, walletHandle: IndyHandler) { (error, resData) in
                    if (error! as NSError).code > 1 {
                        handler("Error in function: \(#function):at line:\(error.debugDescription)")
                    }else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
                            } else {
                                let unPackMessageResult = String.init(data: resData!, encoding: .utf8)
                                print("UnPackMessageResult from .swift::: \(unPackMessageResult!)")
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
    
    private func packMessage(config:String,credential:String,message:String,receiverKeys:String,senderVerkey:String,handler:@escaping(_ result :Any)->()){
        IndyWallet().open(withConfig: config, credentials: credential) { error, IndyHandler in
            if ((error! as NSError).code > 1) {
                handler(error?.localizedDescription as Any)
            } else {
                IndyCrypto.createKey("{}", walletHandle: IndyHandler) { (error, verKey) in
                    if ((error! as NSError).code > 1) {
                        handler(error?.localizedDescription as Any)
                    } else {
                        let messageData = message.data(using: .utf8)
                        IndyCrypto.packMessage(messageData, receivers: receiverKeys, sender: senderVerkey, walletHandle: IndyHandler) { (error, packMessageData) in
                            if ((error! as NSError).code > 1) {
                                handler(error?.localizedDescription as Any)
                            } else {
                                IndyWallet().close(withHandle: IndyHandler) { (error) in
                                    if ((error! as NSError).code > 1) {
                                        handler(error?.localizedDescription as Any)
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
    
    private func cryptoVerify(config:String, credential:String, signVerkey:String, message:Data, signatureRaw:Data,  handler:@escaping(_ result: Any)->()){
        IndyWallet().open(withConfig: config, credentials: credential) { (error, IndyHandler) in
            if (error! as NSError).code > 1 {
                handler("Error in function: \(#function):at line:\(error.debugDescription)")
            }else {
                IndyCrypto.verifySignature(signatureRaw, forMessage: message, key: signVerkey) { (error, isValidSignature) in
                    if (error! as NSError).code > 1 {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
                            } else {
                                print(error?.localizedDescription as Any)
                                handler(error?.localizedDescription as Any)
                            }
                        }
                    }else {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
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
    
    
    
    private func cryptoSign(config:String,credential:String,signerKey:String,messageRaw:String,handler:@escaping(_ result:Any)->()){
        IndyWallet().open(withConfig: config, credentials: credential) { (error, IndyHandler) in
            if (error! as NSError).code > 1 {
                handler("Error in function: \(#function):at line:\(error.debugDescription)")
            }else {
                let rawMessageData = messageRaw.data(using: .utf8)
                IndyCrypto.signMessage(rawMessageData, key: signerKey, walletHandle: IndyHandler) { (error, signature) in
                    if (error! as NSError).code > 1 {
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
                            } else {
                                handler(error?.localizedDescription as Any)
                            }
                        }
                    }else {
                        
                        IndyWallet().close(withHandle: IndyHandler) { (closeWalletError) in
                            if ((closeWalletError! as NSError).code > 1) {
                                handler(closeWalletError?.localizedDescription as Any)
                            } else {
                                if let signature = signature {
                                    print("Signature Data from signMessage: \(signature)")
                                    
                                    let bytePtr = [UInt8](signature)
                                    let length = signature.count
                                    
                                    var valueArray: [AnyHashable] = []
                                    
                                    for i in 0..<length {
                                        print(String(format: "data byte chunk : %x", bytePtr[i]))
                                        let someNumber = NSNumber(value: Int32(bytePtr[i]))
                                        valueArray.append(someNumber)
                                    }
                                    print(valueArray)
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

private func createPoolLedgerConfig(poolConfig:String,handler:@escaping(_ result: Any)->()) {
    let  DEFAULT_POOL_NAME = "pool"
    let PROTOCOL_VERSION = 2
    let filename = getDocumentsDirectory().appendingPathComponent("temp.txn")
    
    do {
        try poolConfig.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        handler(error)
    }
    let config = ["genesis_txn":filename.path]
    
    let configJson = try? JSONSerialization.data(withJSONObject: config, options: [])
    let content = String(data: configJson!, encoding: String.Encoding.utf8)
    
    IndyPool.setProtocolVersion(PROTOCOL_VERSION as NSNumber) { (error) in
        if (error! as NSError).code > 1 {
            handler(error?.localizedDescription as Any)
        }else{
            IndyPool.createPoolLedgerConfig(withPoolName: DEFAULT_POOL_NAME, poolConfig:content) { (error) in
                if (error! as NSError).code > 1 {
                    handler(error?.localizedDescription as Any)
                }else{
                    handler(true)
                }
                
            }
        }
    }
    
}

//}
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
}



