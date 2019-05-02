import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/exceptions/auth.dart';
import 'package:heimdall/model.dart';
import 'package:heimdall/model/user.dart';
import 'package:heimdall/ui/pages/student/account.dart';
import 'package:heimdall/ui/pages/login.dart';
import 'package:heimdall/ui/pages/student/home.dart' as student_home;
import 'package:heimdall/ui/pages/teacher/home.dart' as teacher_home;
import 'package:scoped_model/scoped_model.dart';

final model = new AppModel();

void main() => runApp(App());

class App extends StatelessWidget {
  Future<User> checkExistingConnection(BuildContext context) async {
    try {
      return await model.resumeExistingConnection();
    } on AuthException catch (e) {
      print(e.toString());
      // If the token is invalid, remove it from the storage (it probably has expired)
      if (e.type == AuthExceptionType.invalid_token || e.type == AuthExceptionType.invalid_refresh_token) {
        AppModel.of(context).deleteStoredToken();
      }
    } on ApiConnectException catch (e) {
      print(e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return
      ScopedModel<AppModel>(
        model: model,
        child: MaterialApp(
            title: 'Heimdall',
            home: FutureBuilder<User>(
                future: checkExistingConnection(context),
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Container(child: Center(child: CircularProgressIndicator()), color: Colors.white);
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}'); // TODO : Gestion erreur
                      } else {
                        if (snapshot.data != null) {
                          if (model.user.type == User.STUDENT) {
                            return student_home.Home();
                          }
                          if (model.user.type == User.TEACHER) {
                            return teacher_home.Home();
                          }
                        }
                        return Login();
                      }
                  }
                }
            ),
            routes: {
              '/login': (context) => Login(),
//              '/reset_password': (context) => ResetPassword(),
              '/account': (context) => Account(),
              '/teacher/home': (context) => teacher_home.Home(),
              '/student/home': (context) => student_home.Home(),
            }),
      );
  }
}