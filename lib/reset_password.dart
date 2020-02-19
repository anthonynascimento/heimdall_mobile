import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heimdall/helper/validation.dart';
import 'package:heimdall/model.dart';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  @override
  State createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  String verificationId;
  LoginFormData _data = LoginFormData();
  TextEditingController _urlController = TextEditingController();
  FocusNode _urlFocus = FocusNode();
  FocusNode _usernameFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = AppModel.of(context).api?.apiUrl;
    _urlFocus.addListener(() {

    });
  }

  void resetPassword() async {
    String url = 'http://192.168.1.44:8000/api/utilisateur/reset_mdp';
    Map<String,String> body = {"email": _data.username};
    http.put(Uri.encodeFull(url), body: body , headers: { "Accept" : "application/json"}).then((result) {
  print(result.statusCode);
  print(result.body);
  showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text("Mail envoyé"),
              content: new Text('Vérifiez vos mails'),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  ),
              ],
              );
        });
      
});
 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Heimdall'),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(child: Container(
                padding: EdgeInsets.only(left: 30, right: 30, top: 50),
                child: Column(
                  children: <Widget>[
                    Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: "Mail",
                                  icon: const Icon(Icons.person)),
                              validator: Validator.validateEmail,
                              textInputAction: TextInputAction.next,
                              initialValue: AppModel.of(context).user?.username,
                              focusNode: _usernameFocus,
                              onFieldSubmitted: (val) {
                                _usernameFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocus);
                              },
                              onSaved: (String value) => _data.username = value,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: RaisedButton(
                                      child: const Text('Mot de passe oublié'),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: resetPassword,
                                    ))),
                          ],
                        )),
                  ],
                ))),
            _loading ? Container(
              color: Color.fromRGBO(100, 100, 100, 0.5),
              child: Center(child: CircularProgressIndicator()),
            ) : Container(),
          ],
        )
    );
  }

}

class LoginFormData {
  String serverUrl = '';
  String username = '';
  String password = '';
}
