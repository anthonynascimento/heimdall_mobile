import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/heimdall_api.dart';
import 'package:heimdall/helper/flash.dart';
import 'package:heimdall/model/user.dart';
import 'package:scoped_model/scoped_model.dart';
import "package:http/http.dart" as http;


class AppModel extends Model {
  static AppModel of(BuildContext context) => ScopedModel.of<AppModel>(context);
  final GlobalKey navigator = GlobalKey<NavigatorState>();
  final HeimdallApi api = new HeimdallApi();
  Flash _flash;
  User user;
  bool get isLoggedIn => user != null;

  set flash(flash) => _flash = flash;
  Flash get flash {
    Flash flash = _flash;
    _flash = null;
    return flash;
  }

  Future<void> signIn(String apiUrl, String username, String password) async {
    this.user = await api.signIn(apiUrl, username, password);
  }

  Future<void> signOut() async {
    //await api.delete('token/refresh');
    api.userToken = null;
    user = null;
    deleteStoredToken();
  }

  void deleteStoredToken() {
    final storage = new FlutterSecureStorage();
    storage.delete(key: "userToken");
  }

  String removeLastCharacter(String str) {
   String result = "";
   if ((str != null) && (str.length > 0)) {
      result = str.substring(0, str.length - 1);
   }
   return result;
}

  Future<User> resumeExistingConnection() async {
    print('Getting token from storage');
    final storage = new FlutterSecureStorage();
    // No user in memory (probably the app was closed and reopen)
    final String apiUrl = await storage.read(key: "apiUrl");
    print(apiUrl);
    final String userToken = await storage.read(key: "userToken");
    if(apiUrl== null || apiUrl == "") return null;
    if(userToken==null || userToken == "") return null;
      Map<String,String> headers = {"Authorization": "token $userToken"};
      final responseUser = await http.get(
            '$apiUrl/utilisateur/user_connecte',
      headers: headers);
      print(responseUser.statusCode);
      final data = json.decode(responseUser.body);
      //print(data);
      if (responseUser.statusCode == 200) {
        //print(responseUser.body);
        this.user = User.fromJson(json.decode(responseUser.body));
        return this.user;
      }
    
  }
}
