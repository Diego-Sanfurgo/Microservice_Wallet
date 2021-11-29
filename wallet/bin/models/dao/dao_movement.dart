import 'package:mysql1/mysql1.dart';

import '../../server/flow_response.dart';
import '../movement/movement.dart';
import '../movement/states_types.dart';
import '../../server/environment.dart';

Future<String> getWalletId(String userId) async {
  final db = await _connect();

  try {
    Results wallet = await db
        .query("SELECT idWallet FROM wallet WHERE idUser = ?;", [userId]);
    if (wallet.isNotEmpty) {
      return wallet.first.first.toString();
    } else {
      //The user doesn't have a wallet'
      return '';
    }
  } catch (e) {
    rethrow;
  }
}

//Calls the procedure that calculates actual amount of wallet
Future<double> calculateActualAmount(String walletId) async {
  final db = await _connect();

  try {
    Results walletAmount = await db
        .query("CALL calculate_actual_amount(?)", [int.parse(walletId)]);
    if (walletAmount.isNotEmpty) {
      return walletAmount.first.first;
    } else {
      return -1;
    }
  } on MySqlException catch (ex, stacktrace) {
    print(ex.message);
    print(stacktrace);
    rethrow;
  }
}

Future<ResponseStatus> saveMovement(Movement movement) async {
  final db = await _connect();

  try {
    ResponseStatus res = await db.query("""INSERT INTO movement(
      Wallet_Id,
      Amount,
      Date,
      Description,
      Movement_Type_Id,
      Movement_State_Id,
      Related_Movement_Id)
      VALUES ( ?, ?, ?, ?, ?, ?, ?);""", [
      movement.walletId,
      movement.amount,
      movement.date,
      movement.description,
      movement.movementTypeId,
      movement.movementStateId,
      movement.relatedMovementId
    ]).then((value) async {
      if (value.insertId != null) {
        int movementId = await getMovementId(movement);

        return await updateMovementStateToCompleted(movementId);
      } else {
        return ResponseStatus.NOT_FOUND;
      }
    });

    print(res);
    return res;
  } on MySqlException catch (ex, stacktrace) {
    print(ex.message);
    print(stacktrace);

    return ResponseStatus.SERVER_ERROR;
  }
}

Future<ResponseStatus> updateMovementStateToCompleted(int movementId) async {
  final db = await _connect();

  await db.query(
      "UPDATE movement SET Movement_State_Id =? WHERE idMovement = ?",
      [MovementState.completed.index, movementId]).catchError((error) {
    print(error);

    throw error;
  });

  return ResponseStatus.SUCCESS;
}

Future<ResponseStatus> updateMovementStateToCancelled(int movementId) async {
  final db = await _connect();

  Movement move = await getMovementById(movementId);
  if (move.movementTypeId != 1 ||
      (move.movementStateId != 0 && move.movementStateId != 2)) {
    return ResponseStatus.FORBIDDEN;
  }

  await db.query(
      "UPDATE movement SET Movement_State_Id =? WHERE idMovement = ?",
      [MovementState.cancelled.index, movementId]).catchError((error) {
    print(error);

    throw error;
  });

  return ResponseStatus.SUCCESS;
}

Future<Movement> getMovementById(int movementId) async {
  final db = await _connect();

  Movement res = await db
      .query("SELECT * FROM movement WHERE idMovement = ?", [movementId]).then(
          (value) {
    print(value.first.fields);
    return Movement.fromJson(value.first.fields);
  }).catchError((error) {
    print(error);

    throw error;
  });

  return res;
}

Future<int> getMovementId(Movement movement) async {
  final db = await _connect();

  try {
    final Results res = await db.query("""
    SELECT idMovement FROM movement WHERE
    Wallet_Id = ? AND
    Date = ? AND
    Amount = ? """, [
      movement.walletId,
      movement.date,
      movement.amount,
    ]);

    return res.first.first;
  } on MySqlException catch (ex, stacktrace) {
    print(ex.message);
    print(stacktrace);

    rethrow;
  }
}

Future<MySqlConnection> _connect() async {
  return await Configuration.getDB();
}
