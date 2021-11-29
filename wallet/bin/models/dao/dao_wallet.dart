import 'package:mysql1/mysql1.dart';

import '../../server/environment.dart';
import '../../server/flow_response.dart';

Future<ResponseStatus> createWallet(String userId) async {
  final db = await connect();

  bool alreadyExists = await _validateExists(userId);
  if (alreadyExists) {
    return ResponseStatus.ALREADY_EXISTS;
  }

  try {
    Results result =
        await db.query("INSERT INTO wallet(idUser) VALUES (?)", [userId]);

    print(result.insertId);

    if (result.insertId != null) {
      return ResponseStatus.SUCCESS;
    }
  } on MySqlException catch (ex, stacktrace) {
    print(ex.message);
    print(stacktrace);

    return ResponseStatus.SERVER_ERROR;
  }

  return ResponseStatus.NOT_FOUND;
}

Future<bool> _validateExists(String userId) async {
  MySqlConnection db = await connect();

  bool exists = false;
  try {
    Results result =
        await db.query("SELECT * FROM wallet WHERE idUser = '$userId'");
    if (result.isNotEmpty) {
      exists = true;
    }
  } catch (e) {
    rethrow;
  }

  return exists;
}

Future<MySqlConnection> connect() async {
  return await Configuration.getDB();
}
