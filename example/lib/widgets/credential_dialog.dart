import 'dart:convert';

import 'package:AriesFlutterMobileAgent/Agent/AriesFlutterMobileAgent.dart';
import 'package:AriesFlutterMobileAgent_example/helpers/constants.dart';
import 'package:flutter/material.dart';

class CredentialDialog extends StatefulWidget {
  final dynamic credential;
  final dynamic connection;

  const CredentialDialog({Key key, this.credential, this.connection})
      : super(key: key);

  @override
  _CredentialDialogState createState() => _CredentialDialogState();
}

class _CredentialDialogState extends State<CredentialDialog> {
  List<dynamic> fields = [];
  List<dynamic> filledFields = [];
  List<dynamic> field = [];

  @override
  void initState() {
    super.initState();
  }

  void takeNumber(dynamic fieldName, dynamic text, int index) {
    field.length = fields.length;
    setState(() {
      field.insert(index, text);
    });
  }

  Future submitSchema() async {
    try {
      for (int i = 0; i < fields.length; i++) {
        Map data = {
          'name': fields[i],
          'mime-type': 'image/jpeg',
          'value': field[i] == "" ? "" : field[i],
        };
        filledFields.add(jsonEncode(data));
      }
      await AriesFlutterMobileAgent.sendCredentialProposal(
        widget.connection['verkey'],
        filledFields,
        widget.credential['schema']['schemaLedgerId'],
        widget.credential['credentialDefinitionId'].replaceAll(' ', '_'),
        widget.credential['issuerDid'],
      );
    } catch (exception) {
      throw exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    var fieldsList = widget.credential['schema']['attributes'];
    setState(() {
      fields = fieldsList;
    });
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Constants.padding),
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            child: fields.length > 0
                ? ListView.builder(
                    padding: EdgeInsets.only(top: 5),
                    itemCount: fields.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        height: 50,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: fields[index],
                          ),
                          onChanged: (text) {
                            takeNumber(fields[index], text, index);
                          },
                        ),
                      );
                    },
                  )
                : Text(''),
          ),
          RaisedButton(
            color: Colors.blue,
            onPressed: submitSchema,
            child: Text(
              'Submit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}
