import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../models/dtos/dto_response.dart';
import '../models/movement/movement.dart';
import '../models/movement/states_types.dart';
import '../server/flow_response.dart';
import '../token/token.dart' as token;

Future<Response> refundAmount(Request request) async {
  Map<ResponseStatus, Map?> authUser =
      await token.validateToken(request.headers['Authorization']);
  if (authUser.keys.first != ResponseStatus.SUCCESS) {
    return Response(401, body: "Unauthorized");
  }

  Map userBody = authUser.values.first!;
  String rawBody = await request.readAsString();
  Map body = jsonDecode(rawBody);
  body.addAll(userBody);

  //Creo un nuevo movimiento a partir del body
  Movement newMovement = await Movement.fromBody(body, MovementType.refund,
      relatedId: body['cancelledMovementId']);

  //Asigno el valor contrario del movimiento que se cnacela
  newMovement.amount =
      await Movement.getMovementById(body['cancelledMovementId'])
          .then((value) => value.amount * -1);

  //Cambio el estado del movimiento que se quiere cancelar
  ResponseStatus cancelledResponse =
      await Movement.setStateToCancelled(body['cancelledMovementId']);
  if (cancelledResponse == ResponseStatus.FORBIDDEN) {
    return Response.forbidden(
        "Sólo puede cancelar movimientos salientes de esta cuenta y que tengan estado \"Completado\" ó \"En espera\"");
  }

  //Guardo el movimiento nuevo de reembolso
  ResponseStatus response = await newMovement.save();

  if (response == ResponseStatus.SUCCESS &&
      cancelledResponse == ResponseStatus.SUCCESS) {
    Movement move = await Movement.getMovementFromDB(newMovement);
    Map actualAmount = await Movement.getBalanceByWallet(move.walletId);
    return Response.ok(
        movementResponseDTO(move, actualAmount.values.first).toString());
  }

  switch (response) {
    case ResponseStatus.ERROR:
    case ResponseStatus.SERVER_ERROR:
      return Response.internalServerError(
          body: 'Something went wrong. Internal server error');

    case ResponseStatus.NOT_FOUND:
    default:
      return Response.notFound('This resource could not be found');
  }
}
