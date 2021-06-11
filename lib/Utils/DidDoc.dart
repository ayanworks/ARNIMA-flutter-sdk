enum PublicKeyType {
  RSA_SIG_2018,
  ED25519_SIG_2018,
  EDDSA_SA_SIG_SECP256K1,
}

extension PublicKeyTypeExtension on PublicKeyType {
  String get key {
    switch (this) {
      case PublicKeyType.RSA_SIG_2018:
        return "RsaVerificationKey2018|RsaSignatureAuthentication2018|publicKeyPem";
      case PublicKeyType.ED25519_SIG_2018:
        return "Ed25519VerificationKey2018|Ed25519SignatureAuthentication2018|publicKeyBase58";
      case PublicKeyType.ED25519_SIG_2018:
        return "Secp256k1VerificationKey2018|Secp256k1SignatureAuthenticationKey2018|publicKeyHex";
      default:
        return null;
    }
  }
}

class DidDoc {
  String context;
  String id;
  List<PublicKey> publicKey;
  List<Authentication> authentication;
  List<Service> service;

  DidDoc(
      {this.context,
      this.id,
      this.publicKey,
      this.authentication,
      this.service});

  DidDoc.convertToObject(Map<String, dynamic> json) {
    id = json['id'];
    context = json['@context'];

    if (json['publicKey'] != null) {
      List<PublicKey> publicKeys = [];
      json['publicKey'].forEach((item) {
        publicKeys.add(new PublicKey.fromJson(item));
      });
      publicKey = publicKeys;
    }
    if (json['authentication'] != null) {
      List<Authentication> authentications = [];
      json['authentication'].forEach((value) {
        authentications.add(new Authentication.fromJson(value));
      });
      authentication = authentications;
    }
    if (json['service'] != null) {
      List<Service> services = [];
      json['service'].forEach((value) {
        services.add(new Service.fromJson(value));
      });
      service = services;
    }
  }

  DidDoc.fromJson(Map<String, dynamic> json) {
    context = json['@'];
    id = json['id'];
    if (json['publicKey'] != null) {
      publicKey = new List<PublicKey>();
      json['publicKey'].forEach((value) {
        publicKey.add(new PublicKey.fromJson(value));
      });
    }
    if (json['authentication'] != null) {
      authentication = new List<Authentication>();
      json['authentication'].forEach((value) {
        authentication.add(new Authentication.fromJson(value));
      });
    }
    if (json['service'] != null) {
      service = new List<Service>();
      json['service'].forEach((value) {
        service.add(new Service.fromJson(value));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@context'] = this.context;
    data['id'] = this.id;
    if (this.publicKey != null) {
      data['publicKey'] =
          this.publicKey.map((value) => value.toJson()).toList();
    }
    if (this.authentication != null) {
      data['authentication'] =
          this.authentication.map((value) => value.toJson()).toList();
    }
    if (this.service != null) {
      data['service'] = this.service.map((value) => value.toJson()).toList();
    }
    return data;
  }
}

class PublicKey {
  String id;
  String type;
  String controller;
  String publicKeyBase58;

  PublicKey({this.id, this.type, this.controller, this.publicKeyBase58});

  PublicKey.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    controller = json['controller'];
    publicKeyBase58 = json['publicKeyBase58'];
  }

  Map<String, dynamic> toJsonForAuthentication() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    var key = this.type.split('|');
    data['id'] = this.id;
    data['type'] = key[0];
    data['controller'] = this.controller;
    data['publicKeyBase58'] = this.publicKeyBase58;
    return data;
  }
}

class Authentication {
  String type;
  String publicKey;

  Authentication({this.type, this.publicKey});

  Authentication.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    publicKey = json['publicKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    var key = this.type.split('|');

    data['type'] = key[0];
    data['publicKey'] = this.publicKey;
    return data;
  }
}

class Service {
  String id;
  String type;
  int priority;
  String serviceEndpoint;
  List<String> recipientKeys;
  List<String> routingKeys;

  Service(
      {this.id,
      this.type,
      this.priority,
      this.serviceEndpoint,
      this.recipientKeys,
      this.routingKeys});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    priority = json['priority'];
    serviceEndpoint = json['serviceEndpoint'];

    if (json['routingKeys'] != null) {
      routingKeys = List<String>.from(json['routingKeys']);
    } else {
      routingKeys = [];
    }

    if (json['recipientKeys'] != null) {
      recipientKeys = List<String>.from(json['recipientKeys']);
    } else {
      recipientKeys = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['priority'] = this.priority;
    data['serviceEndpoint'] = this.serviceEndpoint;
    data['recipientKeys'] = this.recipientKeys;
    data['routingKeys'] = this.routingKeys;
    return data;
  }
}
