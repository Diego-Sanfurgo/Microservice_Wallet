import 'dart:convert';

import '../server/flow_response.dart';
import 'package:http/http.dart' as http;

const usersBaseUrl = "localhost:3000";

Future<Map<ResponseStatus, Map?>> validateToken(String? auth) async {
  if (auth == null) {
    return {ResponseStatus.UNAUTHORIZED: null};
  }
  List<String> token = auth.split(" ");

  if (token[1] == "") {
    return {ResponseStatus.UNAUTHORIZED: null};
  }

  Uri url = Uri.http(usersBaseUrl, "/v1/users/current");

  Map? response =
      await http.get(url, headers: {"Authorization": auth}).then((value) {
    if (value.statusCode == 200) {
      print(value.body);

      Map body = jsonDecode(value.body);
      print(body);
      return body;
    }
  }).catchError((ex) {
    print(ex);
    throw ex;
  });

  return {ResponseStatus.SUCCESS: response};
}
