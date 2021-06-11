import 'dart:ui';
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';
import 'package:AriesFlutterMobileAgent_example/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, action, state;
  final dynamic message;
  final List<dynamic> attributes;
  final bool isCredential, showActionButton;
  final BuildContext buildContext;

  const CustomDialogBox({
    Key key,
    this.title,
    this.attributes,
    this.state,
    this.action,
    this.isCredential,
    this.buildContext,
    this.message,
    this.showActionButton,
  }) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  ProgressDialog progressIndicator;

  Future acceptCredential(message) async {
    try {
      progressIndicator.show();
      await AriesFlutterMobileAgent.acceptCredentialOffer(
        message.messageId,
        message.messages,
      );
      progressIndicator.hide();
    } catch (err) {
      progressIndicator.hide();
    }
  }

  Future sendProof(message) async {
    try {
      progressIndicator.show();
      await AriesFlutterMobileAgent.sendProof(
        message.messageId,
        message.messages,
      );
      progressIndicator.hide();
    } catch (exception) {
      progressIndicator.hide();
      throw exception;
    }
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(Constants.padding),
          height: MediaQuery.of(context).size.height / 3,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.attributes.length,
                  itemBuilder: (BuildContext context, int index) {
                    var attribute = widget.attributes[index];
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              attribute['name'],
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              attribute['value'],
                              style: TextStyle(color: Colors.blue[900]),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 2,
                        ),
                      ],
                    );
                  },
                ),
              ),
              widget.isCredential
                  ? widget.state == 'STATE_ACKED'
                      ? new Container(
                          height: 0,
                          width: 0,
                        )
                      : widget.showActionButton
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FlatButton(
                                  color: Colors.grey,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'cancel',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                FlatButton(
                                  color: Colors.blue,
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await acceptCredential(widget.message);
                                  },
                                  child: Text(
                                    widget.action,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Container(
                              height: 0,
                              width: 0,
                            )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(
                          color: Colors.grey,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        FlatButton(
                          color: Colors.blue,
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await sendProof(widget.message);
                          },
                          child: Text(
                            widget.action,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
