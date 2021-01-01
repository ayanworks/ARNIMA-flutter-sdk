# ARNIMA-flutter-sdk

This sdk is compatible to be used with both `Android` and `iOS` platforms. Please refer `Installation` section on how to set up the sdk and start running.

## Dependencies

```
dependencies:
  flutter:
    sdk: flutter

  http: ^0.12.2
  hive: ^1.4.4+1
  hive_flutter: ^0.3.1
  path_provider: ^1.6.22

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^0.8.1
  build_runner: ^1.10.4
```

## Installation

1. Clone this SDK repository
   `git clone *****`
2. Open the pubspec.yaml file located inside the app folder, and add SDK under dependencies.
 ```
  dependencies:
  flutter:
    sdk: flutter

  AriesFlutterMobileAgent:
    path: ../<Your SDK repository path>/ARNIMA-flutter-sdk
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
Xcode 11.7: All other versions will not be compatible with Swift version 5.2 that was used to build the Indy Framework

1. Include below lines on top of your project's `Podfile`.
```
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/hyperledger/indy-sdk.git'
```
2. Change `platform :ios, '9.0'` to `platform :ios, '13.0'`
3. Remove `use_frameworks!` from `Podfile`
4. Do `pod install`.
5. You need to dowload and replace the file "Indy.framework" from Pods folder inside your Mobile app project from the following link (only if your xcode version is above 10.5)
Download from -  https://drive.google.com/file/d/1mbaZPKfiykwIAli2fUdJ8gZ1zNY17AJk/view
Replace at - <Your_Project>/ios/Pods/libindy/
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
`label` : String - Your label to show to the counterparty during connection

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

```json
{"reqSignature":{},"txn":{"data":{"data":{"alias":"Node1","blskey":"4N8aUNHSgjQVgkpm8nhNEfDf6txHznoYREg9kirmJrkivgL4oSEimFF6nsQ6M41QvhM2Z33nves5vfSn9n1UwNFJBYtWVnHYMATn76vLuL3zU88KyeAYcHfsih3He6UHcXDxcaecHVz6jhCYz1P2UZn2bDVruL5wXpehgBfBaLKm3Ba","blskey_pop":"RahHYiCvoNCtPTrVtP7nMC5eTYrsUA8WjXbdhNc8debh1agE9bGiJxWBXYNFbnJXoXhWFMvyqhqhRoq737YQemH5ik9oL7R4NTTCz2LEZhkgLJzB3QRQqJyBNyv7acbdHrAT8nQ9UkLbaVL9NBpnWXBTw4LEMePaSHEw66RzPNdAX1","client_ip":"127.0.0.0","client_port":9702,"node_ip":"127.0.0.0","node_port":9701,"services":["VALIDATOR"]},"dest":"Gw6pDLhcBcoQesN72qfotTgFa7cbuqZpkX3Xo6pLhPhv"},"metadata":{"from":"Th7MpTaRZVRYnPiabds81Y"},"type":"0"},"txnMetadata":{"seqNo":1,"txnId":"fea82e10e894419fe2bea7d96296a6d46f50f93f9eeda954ec461b2ed2950b62"},"ver":"1"}
{"reqSignature":{},"txn":{"data":{"data":{"alias":"Node2","blskey":"37rAPpXVoxzKhz7d9gkUe52XuXryuLXoM6P6LbWDB7LSbG62Lsb33sfG7zqS8TK1MXwuCHj1FKNzVpsnafmqLG1vXN88rt38mNFs9TENzm4QHdBzsvCuoBnPH7rpYYDo9DZNJePaDvRvqJKByCabubJz3XXKbEeshzpz4Ma5QYpJqjk","blskey_pop":"Qr658mWZ2YC8JXGXwMDQTzuZCWF7NK9EwxphGmcBvCh6ybUuLxbG65nsX4JvD4SPNtkJ2w9ug1yLTj6fgmuDg41TgECXjLCij3RMsV8CwewBVgVN67wsA45DFWvqvLtu4rjNnE9JbdFTc1Z4WCPA3Xan44K1HoHAq9EVeaRYs8zoF5","client_ip":"127.0.0.0","client_port":9704,"node_ip":"127.0.0.0","node_port":9703,"services":["VALIDATOR"]},"dest":"8ECVSk179mjsjKRLWiQtssMLgp6EPhWXtaYyStWPSGAb"},"metadata":{"from":"EbP4aYNeTHL6q385GuVpRV"},"type":"0"},"txnMetadata":{"seqNo":2,"txnId":"1ac8aece2a18ced660fef8694b61aac3af08ba875ce3026a160acbc3a3af35fc"},"ver":"1"}
{"reqSignature":{},"txn":{"data":{"data":{"alias":"Node3","blskey":"3WFpdbg7C5cnLYZwFZevJqhubkFALBfCBBok15GdrKMUhUjGsk3jV6QKj6MZgEubF7oqCafxNdkm7eswgA4sdKTRc82tLGzZBd6vNqU8dupzup6uYUf32KTHTPQbuUM8Yk4QFXjEf2Usu2TJcNkdgpyeUSX42u5LqdDDpNSWUK5deC5","blskey_pop":"QwDeb2CkNSx6r8QC8vGQK3GRv7Yndn84TGNijX8YXHPiagXajyfTjoR87rXUu4G4QLk2cF8NNyqWiYMus1623dELWwx57rLCFqGh7N4ZRbGDRP4fnVcaKg1BcUxQ866Ven4gw8y4N56S5HzxXNBZtLYmhGHvDtk6PFkFwCvxYrNYjh","client_ip":"127.0.0.0","client_port":9706,"node_ip":"127.0.0.0","node_port":9705,"services":["VALIDATOR"]},"dest":"DKVxG2fXXTU8yT5N7hGEbXB3dfdAnYv1JczDUHpmDxya"},"metadata":{"from":"4cU41vWW82ArfxJxHkzXPG"},"type":"0"},"txnMetadata":{"seqNo":3,"txnId":"7e9f355dffa78ed24668f0e0e369fd8c224076571c51e2ea8be5f26479edebe4"},"ver":"1"}
{"reqSignature":{},"txn":{"data":{"data":{"alias":"Node4","blskey":"2zN3bHM1m4rLz54MJHYSwvqzPchYp8jkHswveCLAEJVcX6Mm1wHQD1SkPYMzUDTZvWvhuE6VNAkK3KxVeEmsanSmvjVkReDeBEMxeDaayjcZjFGPydyey1qxBHmTvAnBKoPydvuTAqx5f7YNNRAdeLmUi99gERUU7TD8KfAa6MpQ9bw","blskey_pop":"RPLagxaR5xdimFzwmzYnz4ZhWtYQEj8iR5ZU53T2gitPCyCHQneUn2Huc4oeLd2B2HzkGnjAff4hWTJT6C7qHYB1Mv2wU5iHHGFWkhnTX9WsEAbunJCV2qcaXScKj4tTfvdDKfLiVuU2av6hbsMztirRze7LvYBkRHV3tGwyCptsrP","client_ip":"127.0.0.0","client_port":9708,"node_ip":"127.0.0.0","node_port":9707,"services":["VALIDATOR"]},"dest":"4PS3EDQ3dW1tci1Bp6543CfuuebjFrg36kLAUcskGfaA"},"metadata":{"from":"TWwCRQRZ2ZHMJFn9TzLp7W"},"type":"0"},"txnMetadata":{"seqNo":4,"txnId":"aa5e817d7cc626170eca175822029339a444eb0ee8f0bd20d3b0b76e566fb008"},"ver":"1"}
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

`didJson`: Json - Identity information as json

```json
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
"http://127.0.0.0:4000?c_i=eyJAdHlwZSI6ImRpZDpzb3Y6QnpDYnNOWWhNcmpIaXFaRFRVQVNIZztzcGVjL2Nvbm5lY3Rpb25zLzEuMC9pbnZpdGF0aW9uIiwiQGlkIjoiMzQyNmUzYWQtZGQ5Zi00OWZmLWE2Y2QtMGI2OTJmZmIyMDg5IiwibGFiZWwiOiJzYWkiLCJyZWNpcGllbnRLZXlzIjpbIjNHOUtXa3o3aWZwWUNiNUVqWEtab1lndWloQ0FjbmFON2RrN1d5bnAxOWFHIl0sInNlcnZpY2VFbmRwb2ludCI6Imh0dHA6Ly8zNS4xOTMuNjIuMTM2OjQwMDAiLCJyb3V0aW5nS2V5cyI6WyI1TnJyVkJZNUZLWXJ1RkxaaHVXS0hLNjc0aFBZN1M2R2Q1QmhtTG5oazU3MyJdfQ=="
```

**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

var status = await AriesFlutterMobileAgent.acceptInvitation(
    didJson,
    invitationUrl,
);
```

**Returns:**

`Success`: true

## Socket Methods
We are using socket for communication between app and mediator agent.

### socketInit() -> void
---
**Example:**

```dart
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

await AriesFlutterMobileAgent.socketInit();
```
