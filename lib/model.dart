import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/heimdall_api.dart';
import 'package:heimdall/helper/flash.dart';
import 'package:heimdall/model/user.dart';
import 'package:scoped_model/scoped_model.dart';


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

  Future<User> resumeExistingConnection() async {
    // No user in memory (probably the app was closed and reopen)
    if (api.userToken == null) {
      print('Getting token from storage');
      final storage = new FlutterSecureStorage();

      final String apiUrl = await storage.read(key: "apiUrl");
      if (apiUrl == null) {
        return null;
      }
      this.api.apiUrl = apiUrl;

      final String userToken = await storage.read(key: "userToken");
      if (userToken == null) {
        return null;
      }
      this.api.userToken = userToken;
    }

    //this.user = User.fromJson(await api.refreshUserToken());

    return this.user;
  }
}
