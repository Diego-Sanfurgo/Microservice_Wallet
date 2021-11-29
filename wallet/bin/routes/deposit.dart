import 'dart:convert';
import 'package:shelf/shelf.dart';

import '../models/dtos/dto_response.dart';
import '../models/movement/movement.dart';
import '../models/movement/states_types.dart';
import '../server/flow_response.dart';
import '../token/token.dart' as token;

Future<Response> depositAmount(Request request) async {
  Map<ResponseStatus, Map?> authUser =
      await token.validateToken(request.headers['Authorization']);
  if (authUser.keys.first != ResponseStatus.SUCCESS) {
    return Response(401, body: "Unauthorized");
  }

  Map userBody = authUser.values.first!;
  String rawBody = await request.readAsString();
  Map body = jsonDecode(rawBody);
  body.addAll(userBody);

  if (body['amount'] < 0) {
    body['amount'] = body['amount'] * -1;
  }

  Movement newMovement = await Movement.fromBody(body, MovementType.deposit);

  ResponseStatus response = await newMovement.save();

  switch (response) {
    case ResponseStatus.ERROR:
    case ResponseStatus.SERVER_ERROR:
      return Response.internalServerError(
          body: 'Something went wrong. Internal server error');

    case ResponseStatus.SUCCESS:
      Movement move = await Movement.getMovementFromDB(newMovement);
      Map actualAmount = await Movement.getBalanceByWallet(move.walletId);
      return Response.ok(
          movementResponseDTO(move, actualAmount.values.first).toString());

    case ResponseStatus.NOT_FOUND:
    default:
      return Response.notFound('This resource could not be found');
  }
}
