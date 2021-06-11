# Aries Flutter Mobile SDK
This sdk is compatible to be used with both Android and iOS platforms. Please refer Installation section on how to set up the sdk and start running. This SDK is compliant and interoperable with the standards defined in the [Aries RFCs](https://github.com/hyperledger/aries-rfcs).

## Features

#### Finished

✅ [Issue Credential Protocol](https://github.com/hyperledger/aries-rfcs/blob/master/features/0036-issue-credential/README.md)
✅ [Present Proof Protocol](https://github.com/hyperledger/aries-rfcs/blob/master/features/0037-present-proof/README.md)
✅ [Connection Protocol](https://github.com/hyperledger/aries-rfcs/blob/master/features/0160-connection-protocol/README.md)
✅ [Trust Ping Protocol](https://github.com/hyperledger/aries-rfcs/tree/master/features/0048-trust-ping)

#### TODO
⌨️ [Basic Message Protocol](https://github.com/hyperledger/aries-rfcs/blob/master/features/0095-basic-message/README.md)
⌨️ [Mediator coordination protocol](https://github.com/hyperledger/aries-rfcs/blob/master/features/0211-route-coordination/README.md)
⌨️ Connection-less Issuance and Verification
⌨️ Support with other Mediator Agent
⌨️ Store all exchange messages into the Wallet itself



**Notes:** 
Currently, SDK supports our custom build mediator agent and we are planning to open-source the mediator agent soon.




---

## Getting Started

1. Clone this SDK repository
   `git clone https://gitlab.com/Blockster/aries-flutter-sdk.git`
    

4. Open the pubspec.yaml file located inside the DemoApp folder, and add SDK under dependencies.
 ```
  dependencies:
  flutter:
    sdk: flutter

  AriesFlutterMobileAgent:
    path: ../<Your SDK repository path>/aries-flutter-sdk
 ```
3. Install it 
    * From the terminal: Run flutter pub get.
        ### OR
    * From Android Studio/IntelliJ: Click Packages get in the action ribbon at the top of pubspec.yaml.
    * From VS Code: Click Get Packages located in right side of the action ribbon at the top of pubspec.yaml.


### Android
1. Make sure there is a min. SDK version setup in android/build.gradle:.
    ```
    buildscript {
    ext {
            ...
            minSdkVersion = 18
            ...
        }
    }
    ```

### iOS
Xcode : Make sure you have installed Xcode

1. Include below lines on top of your project's `Podfile`.
```
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/hyperledger/indy-sdk.git'
```
2. Change `platform :ios, '9.0'` to `platform :ios, '13.0'`
3. Remove `use_frameworks!` from `Podfile`
4. Do `pod install`.
5. You need to download and replace the file "Indy.framework" from Pods folder inside your Mobile app project from the following link (only if your xcode version is above 10.5)
Download from -  https://drive.google.com/drive/folders/1_WJ3mEHqk5GHH9p5SI4bRKRXPwy5w_0e
Replace at - <Your_Project>/ios/Pods/libindy-objc/libindy-objc
6. Now open .xcworkspace file into the xcode and run the application

### Permissions
1. Read/Write permissions: To access device storage for creating wallet.

## Using the SDK

1. Import the library

    ```dart
    import 'package:AriesFlutterMobileAgent/AriesAgent.dart';
    ```

2. Add `WidgetsFlutterBinding.ensureInitialized();` in main function of app, This binds the framework to the Flutter engine.


3. Use the following methods

## Methods

### init() -> void
---
This method initializes the sdk and setup database.

**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AriesFlutterMobileAgent.init();
  runApp(MyApp());
}
```


### createWallet(config, credential, label) -> Array<String>
---

This method is called after the user has set up their wallet name & passcode for the first time.

`config`: JSON - Wallet configuration that takes in the wallet name as an id (e.g. Proof)

```jsonld
{
    id: <WALLET_NAME>
}
```

`credential`: JSON - Wallet credentials json that takes in the passcode the user has setup during onboarding

```jsonld
{
    key: <PASSCODE>
}
```
`label` : String - Your label to show to the counter party during connection

**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

var response = await AriesFlutterMobileAgent.createWallet(
          {'id': 'John'},
          {'key': '123456'},
          'John',
        );
```

**Returns:**

`Success`: Array[<public_did>, <verkey>, <masterSecretId>]
`Sample Output`: `["K7P6Xoe31NBYn7md8qBm4F", "AsVcY4GUvJyeP2k78vJK2mTuPHT1sSdZjQBXbCUyXEbz", "John"]`

`Error`: Below is a list of anticipated errors
1. **Storage permissions error**. *Sample*: `{"code":"114","message":"org.hyperledger.indy.sdk.IOException: An IO error occurred."}]`
2. **Wallet already error**. *Sample*:
`{"code":"203","message":"Wallet already exists."}]`.


### ConnectWithMediator(url, apiBody, poolConfig) -> Boolean
---

This method connects to an instantiated service of a mediator agent that is in charge of holding messages if the application is offline and to push messages to this `sdk` the moment mobile app is active.

`url`: String - endpoint url of the instantiated mediator agent

```
"http://127.0.0.0:4000"
```

`apiBody`: String - Stringified JSON that contains the wallet information needed to attach to the mediator agent. (myDid, verkey and label you received from response of the create wallet function.)

```dart
jsonEncode({
    'myDid': "<WALLET_PUBLIC_DID>",
    'verkey': "<WALLET_VERIFIED_KEY>",
    'label': "<WALLET_LABEL>",
})
```

`poolConfig`: String - A genesis transaction string.

```
"""{"reqSignature": {}, "txn": {"data": {"data": {"alias": "Node1", "blskey": "4N8aUNHSgjQVgkpm8nhNEfDf6txHznoYREg9kirmJrkivgL4oSEimFF6nsQ6M41QvhM2Z33nves5vfSn9n1UwNFJBYtWVnHYMATn76vLuL3zU88KyeAYcHfsih3He6UHcXDxcaecHVz6jhCYz1P2UZn2bDVruL5wXpehgBfBaLKm3Ba", "blskey_pop": "RahHYiCvoNCtPTrVtP7nMC5eTYrsUA8WjXbdhNc8debh1agE9bGiJxWBXYNFbnJXoXhWFMvyqhqhRoq737YQemH5ik9oL7R4NTTCz2LEZhkgLJzB3QRQqJyBNyv7acbdHrAT8nQ9UkLbaVL9NBpnWXBTw4LEMePaSHEw66RzPNdAX1", "client_ip": "127.0.0.0", "client_port": 9702, "node_ip": "127.0.0.0", "node_port": 9701, "services": ["VALIDATOR"]}, "dest": "Gw6pDLhcBcoQesN72qfotTgFa7cbuqZpkX3Xo6pLhPhv"}, "metadata": {"from": "Th7MpTaRZVRYnPiabds81Y"}, "type": "0"}, "txnMetadata": {"seqNo": 1, "txnId": "fea82e10e894419fe2bea7d96296a6d46f50f93f9eeda954ec461b2ed2950b62"}, "ver": "1"}
            {"reqSignature": {}, "txn": {"data": {"data": {"alias": "Node2", "blskey": "37rAPpXVoxzKhz7d9gkUe52XuXryuLXoM6P6LbWDB7LSbG62Lsb33sfG7zqS8TK1MXwuCHj1FKNzVpsnafmqLG1vXN88rt38mNFs9TENzm4QHdBzsvCuoBnPH7rpYYDo9DZNJePaDvRvqJKByCabubJz3XXKbEeshzpz4Ma5QYpJqjk", "blskey_pop": "Qr658mWZ2YC8JXGXwMDQTzuZCWF7NK9EwxphGmcBvCh6ybUuLxbG65nsX4JvD4SPNtkJ2w9ug1yLTj6fgmuDg41TgECXjLCij3RMsV8CwewBVgVN67wsA45DFWvqvLtu4rjNnE9JbdFTc1Z4WCPA3Xan44K1HoHAq9EVeaRYs8zoF5", "client_ip": "127.0.0.0", "client_port": 9704, "node_ip": "127.0.0.0", "node_port": 9703, "services": ["VALIDATOR"]}, "dest": "8ECVSk179mjsjKRLWiQtssMLgp6EPhWXtaYyStWPSGAb"}, "metadata": {"from": "EbP4aYNeTHL6q385GuVpRV"}, "type": "0"}, "txnMetadata": {"seqNo": 2, "txnId": "1ac8aece2a18ced660fef8694b61aac3af08ba875ce3026a160acbc3a3af35fc"}, "ver": "1"}
            {"reqSignature": {}, "txn": {"data": {"data": {"alias": "Node3", "blskey": "3WFpdbg7C5cnLYZwFZevJqhubkFALBfCBBok15GdrKMUhUjGsk3jV6QKj6MZgEubF7oqCafxNdkm7eswgA4sdKTRc82tLGzZBd6vNqU8dupzup6uYUf32KTHTPQbuUM8Yk4QFXjEf2Usu2TJcNkdgpyeUSX42u5LqdDDpNSWUK5deC5", "blskey_pop": "QwDeb2CkNSx6r8QC8vGQK3GRv7Yndn84TGNijX8YXHPiagXajyfTjoR87rXUu4G4QLk2cF8NNyqWiYMus1623dELWwx57rLCFqGh7N4ZRbGDRP4fnVcaKg1BcUxQ866Ven4gw8y4N56S5HzxXNBZtLYmhGHvDtk6PFkFwCvxYrNYjh", "client_ip": "127.0.0.0", "client_port": 9706, "node_ip": "127.0.0.0", "node_port": 9705, "services": ["VALIDATOR"]}, "dest": "DKVxG2fXXTU8yT5N7hGEbXB3dfdAnYv1JczDUHpmDxya"}, "metadata": {"from": "4cU41vWW82ArfxJxHkzXPG"}, "type": "0"}, "txnMetadata": {"seqNo": 3, "txnId": "7e9f355dffa78ed24668f0e0e369fd8c224076571c51e2ea8be5f26479edebe4"}, "ver": "1"}
            {"reqSignature": {}, "txn": {"data": {"data": {"alias": "Node4", "blskey": "2zN3bHM1m4rLz54MJHYSwvqzPchYp8jkHswveCLAEJVcX6Mm1wHQD1SkPYMzUDTZvWvhuE6VNAkK3KxVeEmsanSmvjVkReDeBEMxeDaayjcZjFGPydyey1qxBHmTvAnBKoPydvuTAqx5f7YNNRAdeLmUi99gERUU7TD8KfAa6MpQ9bw", "blskey_pop": "RPLagxaR5xdimFzwmzYnz4ZhWtYQEj8iR5ZU53T2gitPCyCHQneUn2Huc4oeLd2B2HzkGnjAff4hWTJT6C7qHYB1Mv2wU5iHHGFWkhnTX9WsEAbunJCV2qcaXScKj4tTfvdDKfLiVuU2av6hbsMztirRze7LvYBkRHV3tGwyCptsrP", "client_ip": "127.0.0.0", "client_port": 9708, "node_ip": "127.0.0.0", "node_port": 9707, "services": ["VALIDATOR"]}, "dest": "4PS3EDQ3dW1tci1Bp6543CfuuebjFrg36kLAUcskGfaA"}, "metadata": {"from": "TWwCRQRZ2ZHMJFn9TzLp7W"}, "type": "0"}, "txnMetadata": {"seqNo": 4, "txnId": "aa5e817d7cc626170eca175822029339a444eb0ee8f0bd20d3b0b76e566fb008"}, "ver": "1"}""";
```

**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

var response = await AriesFlutterMobileAgent.connectWithMediator(
        "$MediatorAgentUrl/discover",
        jsonEncode({
            'myDid': "<WALLET_PUBLIC_DID>",
            'verkey': "<WALLET_VERIFIED_KEY>",
            'label': "<WALLET_LABEL>",
        }),
        PoolConfig,
      );
```
**Returns:**

`success` :  returns true

### acceptInvitation(didJson, invitationUrl) -> Boolean
Function is useful for accepting the connection invitation of any aries based agent. Once your connection is established successfully then only you can exchange the credential and proof request.

`didJson`: Json - Identity information as json

```
{
    "did": string, (optional;
            if not provided and cid param is false then the first 16 bit of the verkey will be used as a new DID;
            if not provided and cid is true then the full verkey will be used as a new DID;
            if provided, then keys will be replaced - key rotation use case)
    "seed": string, (optional) Seed that allows deterministic did creation (if not set random one will be created).
                               Can be UTF-8, base64 or hex string.
    "crypto_type": string, (optional; if not set then ed25519 curve is used;
              currently only 'ed25519' value is supported for this field)
    "cid": bool, (optional; if not set then false is used;)
    "method_name": string, (optional) method name to create fully qualified did (Example:  `did:method_name:NcYxiDXkpYi6ov5FcYDi1e`).
}
```
`invitationUrl`: String - Encoded url invitation.

```
"http://127.0.0.0:4000?c_i=eyJAdHlwZSI6ImRpZDpzb3Y6QnpDYnNOWWhNcmpIaXFaRFRVQVNIZztzcGVjL2Nvbm5lY3Rpb25zLzEuMC9pbnZpdGF0aW9uIiwiQGlkIjoiMzQyNmUzYWQtZGQ5Zi00OWZmLWE2Y2QtMGI2OTJmZmIyMDg5IiwibGFiZWwiOiJBeWFud29ya3MiLCJyZWNpcGllbnRLZXlzIjpbIjNHOUtXa3o3aWZwWUNiNUVqWEtab1lndWloQ0FjbmFON2RrN1d5bnAxOWFHIl0sInNlcnZpY2VFbmRwb2ludCI6Imh0dHA6Ly8xMjcuMC4wLjA6NDAwMCIsInJvdXRpbmdLZXlzIjpbIjVOcnJWQlk1RktZcnVGTFpodVdLSEs2NzRoUFk3UzZHZDVCaG1MbmhrNTczIl19"
```

**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

var status = await AriesFlutterMobileAgent.acceptInvitation(
    {},
    invitationUrl,
);
```

**Returns:**

`Success`: true

### getAllConnections() -> Array<Object>
---
Function returns an array of `Objects`. It returns Aries based peer to peer connection records with status. If the status is `COMPLETE` means your connection is established successfully. `REQUESTED` means the connection still is on negotiation state.
**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

var response = await AriesFlutterMobileAgent.getAllConnections();
```

**Returns:**

`Success`: Array[
    {
        `connectionId`: `string`,
        `connection`: `string`,
    }, ...
]
`Sample Output`: 
```
[{
connection: "{"did":"ADGeeTatN2KSqRaSXDb3jv","didDoc":{"@context":"https://w3id.org/did/v1","id":"ADGeeTatN2KSqRaSXDb3jv","publicKey":[{"id":"ADGeeTatN2KSqRaSXDb3jv#1","type":"Ed25519VerificationKey2018","controller":"ADGeeTatN2KSqRaSXDb3jv","publicKeyBase58":"62CKgBmargJ8mpCw5HWvcn2u3KAmvWNQ1ToyUzY5EkiV"}],"authentication":[{"type":"Ed25519SignatureAuthentication2018","publicKey":"ADGeeTatN2KSqRaSXDb3jv#1"}],"service":[{"id":"ADGeeTatN2KSqRaSXDb3jv;indy","type":"IndyAgent","priority":0,"serviceEndpoint":"http://127.0.0.0:4001/endpoint","recipientKeys":["62CKgBmargJ8mpCw5HWvcn2u3KAmvWNQ1ToyUzY5EkiV"],"routingKeys":["ApWggHJ9wSVCjLbjvjgRthjEC8jS1sUKJbBXxjVpPRxS"]}]},"verkey":"62CKgBmargJ8mpCw5HWvcn2u3KAmvWNQ1ToyUzY5EkiV","theirLabel":"ABC FIRM","state":"COMPLETE","theirDid":"6rLDWC9VPNz4f2TNePno9t","theirDidDoc":{"@context":"https://w3id.org/did/v1","id":"did:sov:6rLDWC9VPNz4f2TNePno9t","publicKey":[{"id":"did:sov:6rLDWC9VPNz4f2TNePno9t#1","type":"Ed25519VerificationKey2018","controller":"did:sov:6rLDWC9VPNz4f2TNePno9t","publicKeyBase58":"4Bww2NMiuWy2NBHyJUZXxU16SXydchHJfBwWohuzqTWd"}],"authentication":[{"type":"Ed25519SignatureAuthentication2018","publicKey":"did:sov:6rLDWC9VPNz4f2TNePno9t#1"}],"service":[{"id":"did:sov:6rLDWC9VPNz4f2TNePno9t;indy","type":"IndyAgent","priority":0,"recipientKeys":["4Bww2NMiuWy2NBHyJUZXxU16SXydchHJfBwWohuzqTWd"],"serviceEndpoint":"http://127.0.0.1:8004"}]}}"
connectionId: "62CKgBmargJ8mpCw5HWvcn2u3KAmvWNQ1ToyUzY5EkiV"
}, ...]
```

### listAllCredentials() -> Array<Object>
---
Function returns all stored credentials inside holder's wallet.

**Example:**

``` dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

var response = await AriesFlutterMobileAgent.listAllCredentials();
```

**Returns**
Array[{
        `referent: string`,
        `attrs: {"key1":"raw_value1", "key2":"raw_value2"}`,
        `schema_id: string`,
        `cred_def_id: string`,
        `rev_reg_id: Optional<string>`,
        `cred_rev_id: Optional<string>`
    }]

`Sample Output`
```
[{
"attrs": {expirydate: "19 june 2080", age: "22", place: "England", name: "Jadon"}
"cred_def_id": "XKQLXXzT73roYvSqZjV469:3:CL:238:Indian Passport"
"cred_rev_id": "9"
"referent": "9c9cdb06-c7a6-46ba-bec9-bf4203eef7e9"
"rev_reg_id": "XKQLXXzT73roYvSqZjV469:4:XKQLXXzT73roYvSqZjV469:3:CL:238:Indian 
"schema_id": "XKQLXXzT73roYvSqZjV469:2:Passport:1.1"
}]
```

### getAllActionMessages() -> Array<Object>
---
Function returns an array of `Objects`. It returns the action messages
where the user interaction is required i.e accept the credential, send proof.

**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

var messages = await AriesFlutterMobileAgent.getAllActionMessages();
```
**Returns**

Array[{
        `messageId: string`,
        `messages: string`,
        `auto: bool`,
        `thId: string`,
        `isProcessed: bool`,
        `connectionId: string`,
}]
    
`Sample Output`: 

```
Array<Object>
```

### acceptCredentialOffer(messageId,inboundMessage) -> Boolean
---
Function is used to accept the credential offer which you received from any agent. You can 
fetch the credential from the `getAllActionMessages()`
`messageId`: String - Identifier for unique message

```
"8904"
```

`message`: JSON object - Contains following keys
- message
- recipient_verkey
- sender_verkey

```
"{
"messageId": 853,
"messages": {
	"sender_verkey": "SBNEn54iv2weQmHFrebeJWX7svFS12u9cxL7dPCbzJw",
	"recipient_verkey": "GqDhdigmpk46yfihcFu3xjNUdxYitcZgfnyJ3U4t3AXf",
	"message": {
		"@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/offer-credential",
		"@id": "316e566d-b8ad-4bef-b65c-0aeaa4d8f1f2",
		"~thread": {},
		"credential_preview": {
			"@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/credential-preview",
			"attributes": [{
				"name": "minor",
				"value": "electronics"
			}, {
				"name": "gpa",
				"value": "84"
			}, {
				"name": "major",
				"value": "Computer"
			}, {
				"name": "issue_date",
				"value": "2021-01-21"
			}, {
				"name": "full_name",
				"value": "sairanjit"
			}]
		},
		"comment": "create automated credential exchange",
		"offers~attach": [{
			"@id": "libindy-cred-offer-0",
			"mime-type": "application/json",
			"data": {
				"base64": "eyJzY2hlbWFfaWQiOiAiUExRQlM1bnI0dUVSczRlM0ZNbkZmTjoyOkhpZ2hfU2Nob29sX0RpcGxvbWE6MS4wIiwgImNyZWRfZGVmX2lkIjogIlBMUUJTNW5yNHVFUnM0ZTNGTW5GZk46MzpDTDo0OTpVU0MgSGlnaCBTY2hvb2wgRGlwbG9tYSIsICJrZXlfY29ycmVjdG5lc3NfcHJvb2YiOiB7ImMiOiAiMzIxOTU1OTgzMzk3MTA4MTE0OTE4ODI4MzgwNTEwNTUwNTc1NTc4NjE0Nzg2NDI5NTUxNjI3Mzc1NTUzMDEzNzE0NDE3MjQ1NjY2MzciLCAieHpfY2FwIjogIjYxMzk1NTA3MDg1NDA1MzgxMzc2NzgwOTE5MzE3OTcyOTEyMDMxNDU4NDE4NzI3MTk1NzM1NTA5NjA5MTM5MTc2NzMwMDc0NzE5MTE1NjkyNTEyMDU5NDExODY4NTM5MTI4NzUwMjc5MzY0NjQ0NTM2NDIxOTA5NjcwNTk3Nzc5MDM3NjIwMzA0MTc2MDkzMzA0ODI5NzYzMDMxNjA2MzQyMzEwMzY2MzI0NjAyMDE1OTAwNDA3MTM5MTU4NTEwMzAyNTQyMzcwNjAwMDc5MDQxOTAxMzY2OTMxNjM2MjkzNDAwNzQ3OTE5NDY4NjE0NjU2ODc5NzExNjczOTgxODM3MjMwNDMyMjk1MzUzNjk0NjU2MzE0NTU5MTI2NzgyOTUxNTg4ODg2MzI3NDI2MDQ0NjI5NTAyNjM4NTY1ODk5MjIyNTc5MDIxOTYyNzg5ODUzODg1OTQzOTc4Nzg5OTkxMjYxMzUxOTUxODM0MjUyNTI1NTA5NzE2NTA4NDAyMTY0NDc0NTczNjU5NTE2NzY5NTgyMDYyMTE3NzMwMDE1MTg3MTcyNzU0Njc0MjM4MDY5MTM5NDcwMjEyMzU3Mzk0NzAwMDY4MjMxMzc3MDI1OTMxMjMxNjQwODI4Njk5MTM5NDQwNzAzMzE2NjAzNTM0MjU2NDQxNTY2MTIwMDUxNjM0MTE4NjY1NTQzMDIyNTkwODUyMzA2MjA3NzI5NTMzNDI4NjA1Nzk4MDc3MjQzMDU4MTM2OTY0MzkxODQ4MTc4OTg5OTk4MTA1MDQwOTgzMDI1NzY0NzM4ODQ0NzAxMDQ3MTQxMDE2OTM2MTU1NDI1NDQwMjE2NjE0MzEyMjk3OTc2NDgyNTY4MDEyMzQ2ODA0MzIwNjc1Mzg4MzY0MTM1MTQwNjY1Njc3MDIyMDQxNDQwNiIsICJ4cl9jYXAiOiBbWyJtaW5vciIsICI0MzY3NjEwMjU5NzUwNTMxMTAzNDQ4MzkyMjE3ODUwMjQ5ODQ0MDc3MjQxODIxMDQ5MzAzMDczNTI4NTM0NTQxODA1NDE4ODgwMzIwMjA2NDA0Nzg3MTkzNTczMDU4Nzg4NTUwODA0MjE5ODQzMTk2MzU1NzU5MDQ2NjgwMjc0MzgxNTk2ODIxOTc4ODk3NDM1NDU0MTIxMjIyMDA3MzMxNDkzMjUyMTIwMTIwMTU2NTU1MjQ1MzI3NjMzNzE1MzM5OTczMTY4OTQ1NjM2ODE4NDQ0Mjc1MjQ1ODExODQ5Mjk0NTk0Nzk1Mzg2MTc0MDAwOTMxNzE3OTc2MTgyMjczNjY0OTkzNzQxOTQ3NjkyOTE2ODY2OTU2NDQ3NjcwODk1ODIxNzg3ODQ4MzEyNjc1MTA5MDQ3NTQ2MDYzMTcyMzI4MzIzMTk3NDQwODE5MjAyODIwOTM0MTMxNjM1MzE2ODIwMzAxNjc1NTI2MTYyODI4MzM2MjczNTc1MjAwNDMwMTYxNTg3NjU2MzEyMjk3NDc4Njg2MTEzMDE2OTE1ODcxNjcxODM4MDg4NjI4Nzc1NjA2Njg5ODIzNjk5MzQzNTE4ODIzMzgxMTM5NjgxNDM2MzE2OTYxNDk0MTY1MjgyNzU2MjAyMjA4MDEyMjM1MTk3OTAyODQzODI0NDAxMjk1NjQ4OTExMTczMzgyOTUyNjcwNTMyMDM1NzgyMjMxNjY2MjAyMjQ1NjUyNTk2MzQ4MDIzNDUzNTYwOTY2NDA2MDUzODE1NzQ2MzUzMDQ1Njc5OTgwMTU1NjAzMjg1OTg3OTcwNzk1NTg2MDQ1MjE0NDU1NzE0NjU3ODkxOTkxOTYzNTU1MDk2NjYxMzgxMzg2NTYxMzgwOTk4NDU0MjA4NDA3MjU3ODI5MDk4MjA2MDA3OTMiXSwgWyJtYXN0ZXJfc2VjcmV0IiwgIjQ5MzExMzUxMzYzMzU4NTczNzA0MDAzNDYyMDA4MDEzNzgzNjIyMTc1Mjk2OTM5MTQyNzE1MzMyMzQ2MzcxMzA1MjQ4MTExMzk5NTAwNTc2Nzk3OTc1MTA4ODQ3NzE0NjMyNzQwMjA5ODEzNDAxOTA5Njk2MjEwNDQ4NTU1NjU1MTk5MDc1MTEyNjc4NDYxNzg4NjExMTIyOTM3MjkyODU5MTU4NDk0MTk0MzU2MDc5Mjk0MDk3NzA3ODcyODQwMjQ0MTY0Njc2NTUxMTk0MDkxNzkwNzM1NDE4Mzg2ODQ4MDM4OTg2MzEwNjU5OTc4OTU3NDQ5MTU3MjE0NzMwNjM2ODk2MTI1MDAyMDE5NjU0OTQ2MjU3Nzc5NDg2MjMxNjUxOTY3OTI3MzI0OTE0MTk1NzA0Njg5ODQ5MzM3OTE4MzY2ODE2ODY5MDY1MzQ1MzQ2MDgzMTQwODc5NjAzMDYxNTg1Mjc5NDUxODMwODA2NDY4ODI1NjcwMzk3MjAzNzA4ODIxNTAyODM4Njg1NjU4MDQ5Mjc0ODIwMTI1MTcyNzcyNzUxOTA4MjIwMDEyNDkwNDQwNTgxNzExNjQyMTkyNDg3NzQ5MDAwODI5MTkzNjE4ODY4OTU2MTkzNTY3MjE3MTQ1MjQxMjgxMTUwNTE2MDUzODgwNjQzMDEwNzYzMTU4NzIwOTc2MTMwNDU3NTMyMjEwMTU0NTE5OTg5NjgwOTI0MTYyNDQyMjU3NTY5OTU0OTIzODU5MzAzNTY2Mjk4MjYxNjEwMDk0MzkyODkzMzEyNDk0MTM4NDkyNTQ5MTU2MDM4MDAzODQ1MTIyMTg4NTEwNzA3NjkzODAwNjgyOTk5MjgzNjQ2MDAyNjAxMDc0Mzc4OTI4OTI3NjUzMzcyNTgwMjYwNDgzNjU2NjY2NjEzNiJdLCBbIm1ham9yIiwgIjI5MTUzNjcwOTczMDM2MzYxNDMzMjY0MTkwNTk0NDY0NjUxMTQ2MjA3MjEwNDAzMTMwMTMwMjMxODE0MzYzMTY0OTgzMDA5NzQ0MTA2NzQ4MDkwNTY0NzgzNjUyOTkzOTQ1MjY4MDQyMTcwMTk3NDc4Nzg4NDQ0NzEwODM2NDM5NTUyOTMxOTc5NDY4NTE2NjcyMjY1NDk0ODc1MTg2NjYwNjMyOTQzNjg4MjMzMzU4NjAxNDg1MDYzNTUwMTIyMzY1NzAxMTMzMjkwMjA2NzgzOTk3NjgzMzYyNDI2NTc0MTAyNTk1MjQxNTc0OTgyMjQ2NTAyMDQxNTgwMzczMDc5NDU4MzA5MDUzNDgyOTU2NTgyNzQ3MTIyMzExMTYzODc4MzY2MDU0NjU0Mjk2NDk1OTU5NDAxMTQxOTk3Mzk0OTYzMDYzMzI2OTczMzAzNzgxMTQ0MjM5OTU5Mzk1MDg1MzYxMTI5NTQ0NTQ4Mzg2ODIzOTg1ODE1ODM2NzEzODcxNzI1NjM3MTM0Nzk4NjI1NDgzMTcwMDY3MDYwNDM3MDc5ODU2NzA1MjMxODMxMzc4MzY2NTgzODE5NzQ4Mzg2NTgyNzk2MTA5MjcyOTMyMjEzMTg5MDMwNDYzOTg1NTk5NzE1MDQzMDcwNDc2OTYyNjYxOTA1OTE1Nzg3Mzk2MzU3NzAwNTIyODgzMTI1ODQ0MjI0Mjg5MjM0MDY2MjY3Mjk1NzgxMDM4MzAzNDk3OTY5NDk5OTAxMzEyMTcyMDYwMDQyOTYwNjIyODIxODgyMDkwOTU4NDcxMDgyODE0Mzc5MTc0OTk5NjQ5NTkwMTU2NzI5NzE5NzIyMzQ4MDkyMDcyNTMzMTUxNzE3OTA5ODg5MTkyODI1NTY1MzYyNjUzODEzMDQ2NTc2NDA1NDYwODI3MyJdLCBbImdwYSIsICI1NDc1MTU5NTg3NjY1MTQ2MjI3NjQ5MDE5NjM1MTY2Mjg1MTYyNDk5NDE1Nzk0MzMyNzU5NTI2NTE2MjkwNjQyMDI0OTExNTQyOTQ5ODU1NDk0NTI3ODY1NDMzNDQ2MzY4NDMxMDY5MTM4NjUzMTcxNDk3NDE5MzI3OTE1NDg1MTQyNDYyNjUwMjM3ODY4MzQwOTU2OTU1ODkwNjI4MjY0NTQ1NzQ3ODg4OTcyNjM3ODE5NzE1ODI3NTM4Njg3MzkwNzc1OTkzNTg2ODM4Mjg5MzczMDY3NjAwMzk0NTE0NjI3NzM2Njc0MjMwNjQ4OTI0NDA5MTQ4MzM5MTM1NTU5NTM2MzM4NTExMzc4NDE5MTM0MjIxOTQ0NjY5ODcwNDY4MzczMDY4ODQ2MzU1MTM5MjQ0NDI3NTUwOTc0Mjg2MTc2MzcyMTUwNTA4MTkyNzY1OTc5ODMyMDYyMjk1NzkzMjM3MjcxODY1MjYwMTM2NzkzOTcyNzM4ODE5NDUzOTExOTIxODE3MjgxMjM5NTk2MTU0NDgxMTAyNjM5NTIyODgyMzA5MjM5MDI0NTQwNTUyMTA5Njk1MDM2MDM2MzgyOTYzNjc3MDIxMzU3ODQxMjE3NjczNDc4OTQ0NTMyOTIzMjE2OTQ1OTM0NjMwODY3Njc5NDY2NTUzMjE2NDMxOTUxOTIwNjM3ODgyNDk5MTAwNzkwNzk0OTgxNzIzMjI4NTgwMjA5MTAyMDIzNzIzODQ1MDc5NzQ4NDI0NDkxNDQyMTE5NzQxMTkxNDkwNTgzMTY5OTQ3Njk3MDgyNzU2NjMwODU5MTcxNzk0MzQ2NjE3MjQ0MTAwODM3ODU0MTU5OTk5MDQyNDMyMjU0NDc3MzgxNTU0MjgxODgzNDgzMDAzNjYyNzcyNjYzNjYyMjYwNzMwMDIiXSwgWyJmdWxsX25hbWUiLCAiMTMyNTA1NDg1NDE4Mjg1OTYzOTc1MjU0MzkyMDc2ODg5NTIzNzI4NjU0OTM0NTY2MTkzMDA1MTA5MzI1NjA2Nzc5OTk1MTg3Mzg3MTE3NjU0MDIwNjc5Mjg1MTY3NzcwNTQ0MjEzMDk5OTQyNTM3MTczNjkyNDY3MjUzOTMyMzE1MDA5MjE3OTQ3NzUxMDQ5NTI3NzMzNTMyNjgyMTMwMTcxMDIxODE5Mjc3MzY2NjQyMjU5MDIyMTg2Mjk4MDA1MjI2NDI2NzE3NzgyODAwMjgwMTIwMzg0ODMzNDkyNzAzMTk4Mzg5NDkzNTg1Nzk4NDA0NTk1ODM0MTMwNTMyMzkwMjA2Mzc0NTMxMjkwMjI4NDYwMjc0NzY2MzI5MTI0ODUyNzU0OTI5MDIzOTQ5MDI4NzM3NDI2NzAwMjMzNzM3MDg5ODc3OTY3MTk3NzAzNDk5MjcxNzMxMDM0OTc1MzgwNjczNzMwNzcwNjU1OTU2NjgwNDc3MjIyNzczNTM5Njk3MjYyNzkxNDg0ODAzNjE5Mjg2MzE2MTc5NzMyNzk4NDI0NzI0NzIzOTk2OTM0OTY2MjM1NzYwNjAxMzEwMzU2MjAxNjU0NzQyNTUwOTA4NTE2NDEwNzc0ODI5MTEyNzQ1MDI3ODc1ODIwNTQxNjY5OTEyMDk2MTE0OTQ0NTYyMjczNjcwOTIyNjMyNjU1OTcxOTU0NjYzOTY5NTc4NzU3NTM5MjEwMzU5NjE2NDk0MzgzNDA0MDYzMDE4MzQ1OTE1NTIzMzE4MzgxMjY5NTQ5NTkyMTQ2NTk5NzE4NjAxOTkzNzUzODg5MjM5MTcxMTU3NDIyMTAxNjMxMTg3MDgxMjE2MTIzNjA1MTE1NTU2MDg4NTc0MjA5MTkwOTQ0OTE0Njg0MDE4OTc2OTY1NTkwNTU5Il0sIFsiaXNzdWVfZGF0ZSIsICIyMDIxNDk2NzYwODE3MzQ0MTM1OTYwODU2ODg4MzQ1NDY0OTU0Njk2NTk0NTgwMTAzMDMzMjUyNzYyMTYwMTg4NzE4OTU0NDk5ODMwODQwODgyMDQ0NDk3MjMwMDczMjY5OTM4ODcyOTc2OTE4NjgyMTg2NTMzMTA2NTQ3MjY3MTE2NTI5NTM0Mjk0Njc1MzIwNzkxNTM5NTUwNjc5MzY1NzEwOTc1MTcxNzI5NTM4NzM4OTgyNDM3NTgxOTY1NTk5NTg0NTIwOTkzMzAyMjkzMzM0NDIwMzgwMDkwODM3NzgwODY3ODQzMjI5NjI0NDM0NTQ1MDA5Njg0MTgwMTAzODI3ODE1ODEwNDU2Njg1OTAxNDI2ODIwMTAzMjU5MTEwNzUxMzc1NjgyOTM4NDA3NjIyOTk3NTA1NzM5ODE4MjE5MjA2NTg5MTMxMjQ5NjI2NjY3MjgwMDE1NDg0MzgxODE0MTQ0NzUyNTAyOTE4ODIwMDMwMzEwMTI5MjUxMjE2ODAxNTM5NTEzNzc4ODM2NzIyNTQ3MDAwNzYzMTg0NjU0MjI1NzQyNTQ1MTI0NjE0MzgxMTIwNzMzODc0NDIzNjA2NDcwNTE0NDk1NzIxOTg4Njg2MDkxODYzNjMwNTU1MTkyNzk1MjI1NTIxMzI4OTcyNDE1MDEzNDM3MTAyMjI4MjU1MzkzMzMwOTY5NTEwNTI0ODI4ODA3MjY1MTkxOTg0NjAyMjg4MDk4OTY5MTE1MDgwMzU3MjcyMDAzODUyMzM2MjQ4NjkwMDc1MzA0NDQzMDI3NjE3MjA5OTc4OTg2Njc1NDY2MjI5MTAxMjEyNDk2ODgwNDAwMzk3NzI5MTU3NTU4ODIyNjg4OTYxOTk5MjkwMjEwMDI5ODI0MzYxNTc4NjM5MDIzNjkxMjEyODU0MjYiXV19LCAibm9uY2UiOiAiNjU3MzAyOTc3MjgyNDQxMjkyNDI3Njc4In0 = "
			}
		}]
	}
},
"auto": false,
"thId": "316e566d-b8ad-4bef-b65c-0aeaa4d8f1f2",
"isProcessed": true,
"connectionId": "GqDhdigmpk46yfihcFu3xjNUdxYitcZgfnyJ3U4t3AXf"
}"
```

**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

bool response = await AriesFlutterMobileAgent.acceptCredentialOffer(
    message.messages,
    message.messages,
);
```

**Returns** 
`Success` true

**Error** Below is a list of errors anticipated: Sample
1. **Common invalid structure**
`{"code":"113","message":"Common invalid structure."}]`

### sendProof(messageId, message) -> Boolean
---
Function sends proof against a proof request found inside response of `getAllActionMessages`.

`messageId`: String - Identifier for unique mes

```
"8904"
```

`inboundMessage`: JSON object - Contains following keys
- message
- recipient_verkey
- sender_verkey

```
"{
	"messageId": 854,
	"messages": {
		"sender_verkey": "SBNEn54iv2weQmHFrebeJWX7svFS12u9cxL7dPCbzJw",
		"recipient_verkey": "GqDhdigmpk46yfihcFu3xjNUdxYitcZgfnyJ3U4t3AXf",
		"message": {
			"@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/present-proof/1.0/request-presentation",
			"@id": "677c6af5-b312-47ec-9e9d-6873468fef4d",
			"comment": "Send Proof Request",
			"request_presentations~attach": [{
				"@id": "libindy-request-presentation-0",
				"mime-type": "application/json",
				"data": {
					"base64": "eyJuYW1lIjogIkhpZ2hfU2Nob29sX0RpcGxvbWEiLCAicmVxdWVzdGVkX3ByZWRpY2F0ZXMiOiB7fSwgInJlcXVlc3RlZF9hdHRyaWJ1dGVzIjogeyJhZGRpdGlvbmFsUHJvcDEiOiB7Im5hbWUiOiAibWlub3IiLCAicmVzdHJpY3Rpb25zIjogW3sic2NoZW1hX2lkIjogIlBMUUJTNW5yNHVFUnM0ZTNGTW5GZk46MjpIaWdoX1NjaG9vbF9EaXBsb21hOjEuMCIsICJjcmVkX2RlZl9pZCI6ICJQTFFCUzVucjR1RVJzNGUzRk1uRmZOOjM6Q0w6NDk6VVNDIEhpZ2ggU2Nob29sIERpcGxvbWEifV19LCAiYWRkaXRpb25hbFByb3AyIjogeyJuYW1lIjogIm1ham9yIiwgInJlc3RyaWN0aW9ucyI6IFt7InNjaGVtYV9pZCI6ICJQTFFCUzVucjR1RVJzNGUzRk1uRmZOOjI6SGlnaF9TY2hvb2xfRGlwbG9tYToxLjAiLCAiY3JlZF9kZWZfaWQiOiAiUExRQlM1bnI0dUVSczRlM0ZNbkZmTjozOkNMOjQ5OlVTQyBIaWdoIFNjaG9vbCBEaXBsb21hIn1dfX0sICJ2ZXJzaW9uIjogIjEuMCIsICJub25jZSI6ICI3MTUyNjE4MTAxODY1In0="
				}
			}]
		}
	},
	"auto": false,
	"thId": "677c6af5-b312-47ec-9e9d-6873468fef4d",
	"isProcessed": true,
	"connectionId": "GqDhdigmpk46yfihcFu3xjNUdxYitcZgfnyJ3U4t3AXf"
}"
```

**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

bool response = await await AriesFlutterMobileAgent.sendProof(
    message.messageId,
    message.messages,
);
```

**Returns**
`Success` true

**Error** Below is a list of errors anticipated: Sample
1. **Common invalid structure**
`{"code":"113","message":"Common invalid structure."}]`

## Socket Methods
We are using socket for communication between app and mediator agent.

### socketInit() -> void
---
**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

await AriesFlutterMobileAgent.socketInit();
```