import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/model/etudiant.dart';
import 'package:heimdall/ui/components/loading_button.dart';
import 'package:heimdall/ui/components/named_card.dart';
import 'package:heimdall/ui/components/password_field.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import "package:http/http.dart" as http;

class Account extends StatefulWidget {
  @override
  State createState() => _AccountState();
}

class _AccountState extends Logged<Account> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final Map<String, dynamic> _data = Map<String, dynamic>();
  final Map<String, FocusNode> _focusNodes = {
    'newPassword': FocusNode(),
    'oldPassword': FocusNode(),
  };
  Etudiant student;

  @override
  initState() {
    super.initState();
    student = user; // Cast user as student
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).requestFocus(new FocusNode()); // reset focus
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
            String url = '${api.apiUrl}/utilisateur/modifier_mdp';
    Map<String,String> body = {"password": _data["newPassword"]};
      http.put(Uri.encodeFull(url), body: body , headers: { "Accept" : "application/json", "Authorization": "token ${api.userToken}"}).then((result) {
        print(result.statusCode);
        print(result.body);
        });

      _data.clear();
      setState(() {
        _newPasswordController.text = "";
        _oldPasswordController.text = "";
      });
    } else {
      throw new Exception('Certains champs sont vides ou invalides.');
    }
  }

  Future<void> _signOut() async {
    AppModel.of(context).signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = loading ? Center(child: Stack(children: <Widget>[CircularProgressIndicator()])) :
    SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([

                NamedCard(
                    title: 'Mot de passe',
                    children: <Widget>[
                      Form(
                          key: _formKey,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(children: <Widget>[
                              PasswordField(
                                controller: _newPasswordController,
                                labelText: "Nouveau mot de passe",
                                helperText: "Laissez vide pour ne pas changer",
                                validator: (String value) {
                                  return value.isEmpty ? null : _oldPasswordController.text == value ? 'Doit être différent du mot de passe actuel' : null;
                                },
                                strengthChecker: true,
                                textInputAction: TextInputAction.next,
                                focusNode: _focusNodes['newPassword'],
                                onFieldSubmitted: (val) {
                                  _focusNodes['newPassword'].unfocus();
                                  FocusScope.of(context).requestFocus(_focusNodes['oldPassword']);
                                },
                                onSaved: (String value) => _data['newPassword'] = value,
                              ),
                              PasswordField(
                                controller: _oldPasswordController,
                                labelText: "Mot de passe actuel",
                                validator: (String value) => value.isEmpty ? "Vous devez renseigner votre mot de passe actuel." : null,
                                textInputAction: TextInputAction.done,
                                focusNode: _focusNodes['oldPassword'],
                                onFieldSubmitted: (val) {
                                  _focusNodes['oldPassword'].unfocus();
                                },
                                onSaved: (String value) => _data['oldPassword'] = value,
                              ),
                              ButtonTheme.bar(
                                child: ButtonBar(
                                  children: <Widget>[
                                    LoadingButton(
                                      text: 'ENREGISTRER',
                                      buttonType: ButtonType.FlatButton,
                                      action: _updatePassword,
                                      errorAction: showErrorDialog,
                                      successText: "Mot de passe mis à jour !",
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ))
                    ]
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FlatButton(
                    splashColor: Colors.grey,
                    child: Text('Déconnexion'),
                    onPressed: _signOut,
                  ),
                ),
              ]),
            )
          ],
        )
    );

    return Scaffold(
      key: scaffoldKey,
      body: _body,
    );
  }
}