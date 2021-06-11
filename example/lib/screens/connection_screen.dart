import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:AriesFlutterMobileAgent_example/helpers/helpers.dart';
import 'package:AriesFlutterMobileAgent_example/screens/connection_detail_screen.dart';
import 'package:AriesFlutterMobileAgent_example/screens/qrcode_screen.dart';
import 'package:AriesFlutterMobileAgent_example/widgets/custom_dialog_box.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';

import 'package:AriesFlutterMobileAgent/AriesAgent.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ConnectionScreen extends StatefulWidget {
  static const routeName = '/connections';
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  ProgressDialog progressIndicator;
  String label = "";
  String endPoint = "";
  List<dynamic> connectionList = [];
  List<dynamic> credentialList = [];
  List<dynamic> messageList = [];
  String title = "Home";

  Future eventListener() async {
    emitterAriesSdk.on("SDKEvent", null, (ev, context) async {
      await getConnections();
      await getAllCredentials();
      await getAllActionMessages();
    });
  }

  void connectSocket() async {
    try {
      var sdkDB = await AriesFlutterMobileAgent.getWalletData();
      if (sdkDB != null) {
        AriesFlutterMobileAgent.socketInit();
      }
    } catch (exception) {
      print('Oops! Something went wrong. Please try again later. $exception');
      throw exception;
    }
  }

  addNewConnection() async {
    var result = await BarcodeScanner.scan();
    Object val = decodeInvitationFromUrl(result.rawContent);
    Map<String, dynamic> values = jsonDecode(val);

    if (values['serviceEndpoint'] != null) {
      setState(() {
        label = values['label'];
        endPoint = values['serviceEndpoint'];
      });
      showAlertDialog(result.rawContent);
    }
  }

  showAlertDialog(invitation) {
    Widget confirm = FlatButton(
      child: Text("CONFIRM"),
      onPressed: () {
        Navigator.pop(context);
        progressIndicator.show();
        acceptInvitation(invitation);
      },
      color: Colors.blue,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(30.0),
      ),
      minWidth: MediaQuery.of(context).size.width - 30,
    );

    Widget cancel = FlatButton(
      child: Text("CANCEL"),
      onPressed: Navigator.of(context, rootNavigator: true).pop,
      textColor: Colors.blue,
      color: Colors.white,
      minWidth: MediaQuery.of(context).size.width - 30,
    );

    AlertDialog alert = AlertDialog(
      title: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text:
                  'Please confirm do you want to setup secure connection with ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
            child: Column(
          children: [
            confirm,
            cancel,
          ],
        ))
      ],
    );

    showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  Future acceptInvitation(invitation) async {
    try {
      await AriesFlutterMobileAgent.acceptInvitation(
        {},
        invitation,
      );
      progressIndicator.hide();
      await AriesFlutterMobileAgent.socketInit();
      setState(() {
        getConnections();
      });
    } catch (exception) {
      throw exception;
    }
  }

  Future getConnections() async {
    List<dynamic> connections =
        await AriesFlutterMobileAgent.getAllConnections();
    setState(() {
      connectionList = connections;
    });
  }

  Future getAllCredentials() async {
    try {
      progressIndicator.show();
      List<dynamic> credentials =
          await AriesFlutterMobileAgent.listAllCredentials(filter: {});
      progressIndicator.hide();
      setState(() {
        credentialList = credentials;
      });
    } catch (exception) {
      print("error in listallcred $exception");
      throw exception;
    }
  }

  Future getAllActionMessages() async {
    try {
      List<dynamic> messages =
          await AriesFlutterMobileAgent.getAllActionMessages();
      setState(() {
        messageList = messages;
      });
    } catch (exception) {
      throw exception;
    }
  }

  Future createInvitation() async {
    var qrcode = await AriesFlutterMobileAgent.createInvitation({});
    Navigator.pushNamed(
      context,
      QRcodeScreen.routeName,
      arguments: ScreenArguments(qrcode),
    );
  }

  void navigateToConnectionDetail(connection) {
    Navigator.pushNamed(
      context,
      ConnectionDetailScreen.routeName,
      arguments: ConnectionDetailArguments(connection),
    );
  }

  @override
  void initState() {
    super.initState();
    eventListener();
    getConnections();
    connectSocket();
    tabController = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    progressIndicator = new ProgressDialog(context);
    progressIndicator.style(
      message: '   Please wait ...',
      borderRadius: 10.0,
      backgroundColor: Colors.black54,
      progressWidget: CircularProgressIndicator(
        strokeWidth: 3,
      ),
      messageTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Connections"),
              Tab(text: "Credentials"),
              Tab(text: "Actions"),
            ],
          ),
          title: Text("Home"),
          automaticallyImplyLeading: false,
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: getConnections,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: createInvitation,
                    child: Text('create Invitation'),
                  ),
                  RaisedButton(
                    onPressed: addNewConnection,
                    child: Text('Add new Connection'),
                    color: Colors.blue[200],
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 5),
                      itemCount: connectionList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var connection =
                            jsonDecode(connectionList[index].connection);
                        if (connectionList.length == 0) {
                          return Center(
                            child: Text('You dont have any connections yet'),
                          );
                        }
                        return GestureDetector(
                          onTap: () => navigateToConnectionDetail(connection),
                          child: Card(
                            shadowColor: Colors.grey,
                            child: ListTile(
                              leading: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  padding: EdgeInsets.symmetric(vertical: 4.0),
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    child: Icon(Icons.verified),
                                  ),
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios),
                              title: Text(connection['theirLabel']),
                              subtitle: Text('State :  ${connection['state']}'),
                              selectedTileColor: Colors.orange,
                              contentPadding: EdgeInsets.all(7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: getAllCredentials,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 5),
                      itemCount: credentialList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (credentialList.length == 0) {
                          return Center(
                            child: Text('You dont have any credentials yet'),
                          );
                        }
                        List attrsData = [];
                        credentialList[index]['attrs'].forEach((key, value) {
                          var data = {
                            "name": key,
                            "value": value,
                          };
                          attrsData.add(data);
                        });
                        return Card(
                          shadowColor: Colors.grey,
                          child: ListTile(
                            leading: Container(
                              height: 40,
                              width: 40,
                              child: Icon(
                                Icons.card_membership,
                                color: Colors.amber,
                              ),
                            ),
                            title: Text(credentialList[index]['cred_def_id']
                                .split(':')[4]),
                            contentPadding: EdgeInsets.all(7),
                            trailing: GestureDetector(
                              onTap: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                    title: 'Credential',
                                    action: "Accept",
                                    attributes: attrsData,
                                    isCredential: true,
                                    showActionButton: false,
                                  );
                                },
                              ),
                              child: Container(
                                height: 35,
                                width: 100,
                                alignment: Alignment.center,
                                color: Colors.blue,
                                child: Text(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                    backgroundColor: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: getAllActionMessages,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 5),
                      itemCount: messageList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (messageList.length == 0) {
                          return Text('You dont have any messages');
                        }
                        if (jsonDecode(messageList[index].messages)['message']
                                ['@type'] ==
                            "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/offer-credential") {
                          List<dynamic> attributes =
                              jsonDecode(messageList[index].messages)['message']
                                  ['credential_preview']['attributes'];
                          return Card(
                            shadowColor: Colors.grey,
                            child: ListTile(
                              leading: Container(
                                height: 40,
                                width: 40,
                                child: Icon(
                                  Icons.card_membership,
                                  color: Colors.amber,
                                ),
                              ),
                              title: Text('Credential'),
                              subtitle: Text('state'),
                              contentPadding: EdgeInsets.all(7),
                              trailing: GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: 'Credential',
                                      action: "Accept",
                                      attributes: attributes,
                                      message: messageList[index],
                                      isCredential: true,
                                      showActionButton: true,
                                    );
                                  },
                                ),
                                child: Container(
                                  height: 35,
                                  width: 100,
                                  alignment: Alignment.center,
                                  color: Colors.blue,
                                  child: Text(
                                    'View & Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      backgroundColor: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        if (jsonDecode(messageList[index].messages)['message']
                                ['@type'] ==
                            "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/present-proof/1.0/request-presentation") {
                          var base64Data =
                              jsonDecode(messageList[index].messages)['message']
                                      ['request_presentations~attach'][0]
                                  ['data']['base64'];
                          Map<String, dynamic> proofData =
                              jsonDecode(decodeBase64(base64Data));
                          log(proofData.toString());
                          List keys =
                              proofData['requested_attributes'].keys.toList();
                          List predicatesKeys =
                              proofData['requested_predicates'].keys.toList();
                          List attrsData = [];
                          keys.asMap().forEach((index, key) {
                            var data = {
                              "name": proofData['requested_attributes'][key]
                                      ['restrictions'][0]['cred_def_id']
                                  .split(':')[4],
                              "value": proofData['requested_attributes'][key]
                                  ['name']
                            };
                            attrsData.add(data);
                          });
                          predicatesKeys.asMap().forEach((index, key) {
                            var data = {
                              "name": proofData['requested_predicates'][key]
                                      ['restrictions'][0]['cred_def_id']
                                  .split(':')[4],
                              "value": proofData['requested_predicates'][key]
                                      ['name'] +
                                  " " +
                                  proofData['requested_predicates'][key]
                                          ['p_type']
                                      .toString() +
                                  " " +
                                  proofData['requested_predicates'][key]
                                          ['p_value']
                                      .toString()
                            };
                            attrsData.add(data);
                          });
                          return Card(
                            shadowColor: Colors.grey,
                            child: ListTile(
                              leading: Container(
                                height: 40,
                                width: 40,
                                child: Icon(
                                  Icons.domain_verification,
                                  color: Colors.amber,
                                ),
                              ),
                              title: Text('Presentation'),
                              subtitle: Text('state'),
                              contentPadding: EdgeInsets.all(7),
                              trailing: GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: 'Proof',
                                      action: "Send",
                                      attributes: attrsData,
                                      message: messageList[index],
                                      isCredential: false,
                                      buildContext: context,
                                    );
                                  },
                                ),
                                child: Container(
                                  height: 35,
                                  width: 70,
                                  alignment: Alignment.center,
                                  color: Colors.blue,
                                  child: Text(
                                    'Send',
                                    style: TextStyle(
                                      color: Colors.white,
                                      backgroundColor: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
