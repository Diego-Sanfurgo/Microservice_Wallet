import 'dart:convert';

import 'package:intl/intl.dart';

import '../../server/flow_response.dart';
import '../dao/dao_movement.dart' as dao;
import 'states_types.dart';

Movement movementFromJson(String str) => Movement.fromJson(json.decode(str));

String movementToJson(Movement data) => json.encode(data.toJson());

DateFormat formatDate = DateFormat('yyyy-MM-dd hh:mm:ss');

class Movement {
  Movement({
    this.idMovement,
    required this.walletId,
    required this.amount,
    required this.date,
    this.description,
    required this.movementTypeId,
    required this.movementStateId,
    this.relatedMovementId,
  });

  int? idMovement;
  int walletId;
  double amount;
  String date;
  String? description;
  int movementTypeId;
  int movementStateId;
  int? relatedMovementId;

  factory Movement.fromJson(Map<String, dynamic> json) => Movement(
        idMovement: json["idMovement"],
        walletId: json["Wallet_Id"],
        amount: json["Amount"].toDouble(),
        date: json["Date"].toString(),
        description: json["Description"],
        movementTypeId: json["Movement_Type_Id"],
        movementStateId: json["Movement_State_Id"],
        relatedMovementId: json["Related_Movement_Id"],
      );

  Map<String, dynamic> toJson() => {
        "Id_Movement": idMovement,
        "Wallet_Id": walletId,
        "Amount": amount,
        "Date": date,
        "Description": description,
        "Movement_Type_Id": movementTypeId,
        "Movement_Status_Id": movementStateId,
        "Related_Movement_Id": relatedMovementId,
      };

  static Future<Movement> fromBody(dynamic body, MovementType type,
      {int? relatedId}) async {
    return Movement(
        walletId: int.parse(await Movement.getWalletId(body['id'])),
        amount: body['amount'] ?? 0,
        date: formatDate.format(DateTime.now()),
        description: body['description'],
        movementTypeId: type.index,
        movementStateId: MovementState.waiting.index,
        relatedMovementId: relatedId);
  }

  Future<ResponseStatus> save() async {
    try {
      return await dao.saveMovement(this);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<Movement> getMovementFromDB(Movement movement) async {
    try {
      int movementId = await dao.getMovementId(movement);
      return await dao.getMovementById(movementId);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<Movement> getMovementById(int movementId) async {
    try {
      Movement movement = await dao.getMovementById(movementId);
      return movement;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<ResponseStatus> setStateToCancelled(int movementId) async {
    try {
      ResponseStatus movementToCancell =
          await dao.updateMovementStateToCancelled(movementId);
      return movementToCancell;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<String> getWalletId(String userId) async {
    try {
      return await dao.getWalletId(userId);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<Map<ResponseStatus, double?>> getBalanceByUser(
      String userId) async {
    try {
      String walletId = await dao.getWalletId(userId);
      if (walletId == '') {
        return {ResponseStatus.NO_WALLET: null};
      }
      double actualAmount = await dao.calculateActualAmount(walletId);
      if (actualAmount == -1) {
        return {ResponseStatus.NOT_FOUND: null};
      }
      return {ResponseStatus.SUCCESS: actualAmount};
    } catch (e) {
      print(e);
      return {ResponseStatus.SERVER_ERROR: null};
    }
  }

  static Future<Map<ResponseStatus, double?>> getBalanceByWallet(
      int walletId) async {
    try {
      double actualAmount =
          await dao.calculateActualAmount(walletId.toString());
      if (actualAmount == -1) {
        return {ResponseStatus.NOT_FOUND: null};
      }
      return {ResponseStatus.SUCCESS: actualAmount};
    } catch (e) {
      print(e);
      return {ResponseStatus.SERVER_ERROR: null};
    }
  }
}
