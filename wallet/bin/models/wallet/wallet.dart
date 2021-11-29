import 'dart:convert';

import '../../server/flow_response.dart';
import '../dao/dao_wallet.dart' as dao;

Wallet walletFromJson(String str) => Wallet.fromJson(json.decode(str));

String walletToJson(Wallet data) => json.encode(data.toJson());

class Wallet {
  Wallet({
    required this.idWallet,
    required this.idUser,
  });

  int idWallet;
  String idUser;

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        idWallet: json["idWallet"],
        idUser: json["idUser"],
      );

  Map<String, dynamic> toJson() => {
        "idWallet": idWallet,
        "idUser": idUser,
      };

  static Future<ResponseStatus> createWallet(String userId) async {
    try {
      return await dao.createWallet(userId);
    } catch (e) {
      rethrow;
    }
  }
}
