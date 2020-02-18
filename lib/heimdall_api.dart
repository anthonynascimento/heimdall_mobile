import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/exceptions/auth.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/etudiant.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/model/user.dart';
import "package:http/http.dart" as http;
import 'package:onesignal/onesignal.dart';

import 'model/class_group.dart';

class HeimdallApi {
  String apiUrlProtocol;
  String apiUrlHostname;
  String apiUrlBaseEndpoint;
  String userToken;
  http.Client client = new http.Client();

  Future<List<Etudiant>> getStudentsInClass(int classId) async {
    dynamic result = await get('class/$classId/students');
    return new List<Etudiant>.from(result.map((x) => Etudiant.fromJson(x)));
  }

  Future<User> getUserFromToken(String token) async {
    dynamic result = await get('utilisateur/user_connecte', authHeader);
    return User.fromJson(result);
  }

  Future<List<ClassGroup>> getClasses() async {
    dynamic result = await get('class');
    return new List<ClassGroup>.from(result.map((x) => ClassGroup.fromJson(x)));
  }

  Future<List<RollCall>> getRollCalls([int limit]) async {
    dynamic result = await get('rollcall', limit == null ? null : {'limit': limit.toString()});
    return new List<RollCall>.from(result.map((x) => RollCall.fromJson(x)));
  }

  Future<List<RollCall>> getRollCallsLastWeek() async {
    dynamic result = await get('rollcall/lastweek');
    return new List<RollCall>.from(result.map((x) => RollCall.fromJson(x)));
  }

  Future<RollCall> updateRollCall(RollCall rollCall) async {
    dynamic result = await put('rollcall/${rollCall.id}', rollCall.toJson());
    return RollCall.fromJson(result);
  }

  Future<RollCall> createRollCall(RollCall rollCall) async {
    dynamic result = await post('rollcall', rollCall.toJson());
    return RollCall.fromJson(result);
  }

  Future<List<StudentPresence>> getStudentPresences() async {
    dynamic result = await get('student/presence');
    return new List<StudentPresence>.from(result.map((x) => StudentPresence.fromJson(x)));
  }

  Future<List<StudentPresence>> getStudentRetards() async {
    dynamic result = await get('student/Retards');
    return new List<StudentPresence>.from(result.map((x) => StudentPresence.fromJson(x)));
  }

  Future<List<String>> getExcuses() async {
    dynamic result = await get('student/presence/excuses');
    return new List<String>.from(result);
  }

  void ResetPassword() async {
    dynamic result = await get('student/reset_password');
  }

  Map<String, String> get authHeader {
    return {
      HttpHeaders.authorizationHeader: 'token $userToken',
    };
  }

  String get serverRootUrl {
    return apiUrlProtocol + '://' + apiUrlHostname + '/';
  }

  String get apiUrl {
    if (apiUrlProtocol == null || apiUrlHostname == null || apiUrlBaseEndpoint == null) {
      return null;
    }
    String url = apiUrlProtocol + '://' + apiUrlHostname + apiUrlBaseEndpoint;
    return url;
  }

  set apiUrl(String url) {
    Uri uri = Uri.parse(url);
    apiUrlProtocol = uri.scheme;
    apiUrlHostname = uri.host;
    if(!apiUrlHostname.endsWith(':8000')) {
      apiUrlHostname = apiUrlHostname + ':8000';
    }
    apiUrlBaseEndpoint = uri.path;
    if (apiUrlBaseEndpoint.endsWith('/')) {
      apiUrlBaseEndpoint = apiUrlBaseEndpoint.substring(0, apiUrlBaseEndpoint.length - 1);
    }
  }

  Uri getApiUri(String endpoint, [Map<String, String> parameters]) {
    Uri uri;
    if (apiUrlProtocol == 'https') {
      uri = Uri.https(apiUrlHostname, apiUrlBaseEndpoint + '/' + endpoint, parameters);
    } else {
      uri = Uri.http(apiUrlHostname, apiUrlBaseEndpoint + '/' + endpoint, parameters);
    }
    return uri;
  }

  /*Future<Map<String, dynamic>> refreshUserToken() async {
    if (userToken == null && apiUrlHostname == null) {
      throw new AuthException(AuthExceptionType.not_authenticated);
    }
    return userToken.refresh(apiUrl);
  }*/

  Future<dynamic> _sendRequest(http.BaseRequest request, { bool refreshed = false }) async {
    if (userToken == null && apiUrl == null) {
      throw new AuthException(AuthExceptionType.not_authenticated);
    }

    /*if (userToken.isTokenExpired) {
      refreshUserToken();
    }*/
    
    request.headers[HttpHeaders.authorizationHeader] = 'token $userToken';
    request.headers[HttpHeaders.acceptHeader] = ContentType.json.mimeType;
    request.headers[HttpHeaders.contentTypeHeader] = ContentType.json.mimeType;
    http.StreamedResponse response = await client.send(request)
        .timeout(Duration(seconds: 30), onTimeout: () {
      throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
    });

    final responseBody = json.decode((await http.Response.fromStream(response)).body);
    print(responseBody);
    switch (response.statusCode) {
      case 200:
      case 201:
        return responseBody;
      case 401:
      // The token may have expired, we try to refresh it and send the request again
        if (refreshed == true) { // Second 401 => logout.
          throw new AuthException(AuthExceptionType.invalid_token);
          // TODO : Redirection login screen, connection refused
        }
        //refreshUserToken();
        return _sendRequest(request, refreshed: true);
      default:
        String message = response.reasonPhrase;
        if (responseBody is Map<String, dynamic> && responseBody.containsKey('message')) {
          message = responseBody['message'];
        }
        throw new ApiConnectException(type: ApiConnectExceptionType.http, responseStatusCode: response.statusCode, errorMessage: message);
    }
  }

  Future<dynamic> get(String endpoint, [Map<String, String> parameters]) async {
    return _sendRequest(new http.Request("GET", getApiUri(endpoint, parameters)));
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final http.Request request = new http.Request("POST", getApiUri(endpoint));
    request.body = json.encode(data);
    return _sendRequest(request);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final http.Request request = new http.Request("POST", getApiUri(endpoint));
    request.body = json.encode(data);
    return _sendRequest(request);
  }

  Future<dynamic> delete(String endpoint) async {
    return _sendRequest(new http.Request("DELETE", getApiUri(endpoint)));
  }

  _registerOneSignal(String onesignalAppId, User user) async {
    try {
      print('REGISTER TO ONESIGNAL : ' + onesignalAppId);
      await OneSignal.shared.init(onesignalAppId, iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: true
      });
      await OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

      OSPermissionSubscriptionState state = await OneSignal.shared.getPermissionSubscriptionState();

      print('ONESIGNAL USER ID : ' + state.subscriptionStatus.userId);

      dynamic result = await post('device_subscribe', { 'id': state.subscriptionStatus.userId});
      print('ONESIGNAL SUBSCRIBE API RESULT : ');
      print(result);
    } catch (e) {
      print("FAIL ONESIGNAL : " + e.toString());
    }
  }

  Future<User> signIn(String apiUrl, String username, String password) async {
    if (apiUrl.isEmpty || username.isEmpty || password.isEmpty) {
      throw new AuthException(AuthExceptionType.bad_credentials);
    }
    this.apiUrl = apiUrl;
    http.Response response;
    try {
      response = await http.post('$apiUrl/utilisateur/connexion',
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
          body: '{"username":"$username","password":"$password"}')
          .timeout(Duration(seconds: 10), onTimeout: () {
            throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
          }
      );
    } on SocketException catch (e) {
      throw new ApiConnectException(type: ApiConnectExceptionType.unknown, errorMessage: e.toString());
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      this.userToken = data['token'];
      print(this.getUserFromToken(data['token']));
      final User user = User.fromJson(data['user']);
      

      _registerOneSignal(data['onesignal_app_id'], user);

      // Save the url & token on the phone to be able to reconnect the user later
      final storage = new FlutterSecureStorage();
      storage.write(key: 'apiUrl', value: apiUrl);
      storage.write(key: 'userToken', value: json.encode(userToken));

      return user;
    }

    if (response.statusCode == 401) {
      throw new AuthException(AuthExceptionType.bad_credentials);
    }

    throw new AuthException(AuthExceptionType.unknown);
  }
}