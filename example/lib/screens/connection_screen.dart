import 'dart:convert';

import 'package:AriesFlutterMobileAgent_example/helpers/helpers.dart';
import 'package:AriesFlutterMobileAgent_example/screens/qrcode_screen.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';

import 'package:AriesFlutterMobileAgent/AriesAgent.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ConnectionScreen extends StatefulWidget {
  static const routeName = '/connections';
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  ProgressDialog progressIndicator;
  String label = "";
  String endPoint = "";
  List<ConnectionData> connectionList = [];

  void connectSocket() async {
    try {
      var sdkDB = await DBServices.getWalletData();
      if (sdkDB != null) {
        AriesFlutterMobileAgent.socketInit();
      }
    } catch (error) {
      print('Oops! Something went wrong. Please try again later. $error');
    }
  }

  addNewConnection() async {
    var result = await BarcodeScanner.scan();
    print(result.rawContent);
    Object val = decodeInvitationFromUrl(result.rawContent);
    Map<String, dynamic> values = jsonDecode(val);
    print(values);

    print(values['label']);
    print(values['serviceEndpoint']);

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

    // show the dialog
    showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  Future acceptInvitation(invitation) async {
    try {
      var status = await AriesFlutterMobileAgent.acceptInvitation(
        {},
        invitation,
      );
      print("is Invitation Accepted::: $status");

      progressIndicator.hide();
      await AriesFlutterMobileAgent.socketInit();
      setState(() {
        getConnections();
      });
    } catch (err) {
      print("erro in main accin $err");
    }
  }

  Future getConnections() async {
    List<ConnectionData> connections = await DBServices.getAllConnections();
    setState(() {
      connectionList = connections;
    });
  }

  Future createInvitation() async {
    var qrcode = await AriesFlutterMobileAgent.createInvitation({});
    Navigator.pushNamed(
      context,
      QRcodeScreen.routeName,
      arguments: ScreenArguments(qrcode),
    );
  }

  @override
  void initState() {
    super.initState();
    getConnections();
    connectSocket();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
      ),
      body: RefreshIndicator(
        onRefresh: getConnections,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: createInvitation,
              child: Text('create Invitation'),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 5),
                itemCount: connectionList.length,
                itemBuilder: (BuildContext context, int index) {
                  var connection = jsonDecode(connectionList[index].connection);
                  if (connectionList.length == 0) {
                    return Center(
                      child: Text('Go ahead and connect with someone'),
                    );
                  }
                  return GestureDetector(
                    onTap: () {},
                    child: Card(
                      shadowColor: Colors.grey,
                      child: ListTile(
                        leading: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {},
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
      floatingActionButton: FloatingActionButton(
        onPressed: addNewConnection,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
