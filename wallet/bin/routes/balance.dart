import 'package:shelf/shelf.dart';

import '../models/dtos/dto_response.dart';
import '../models/movement/movement.dart';
import '../server/flow_response.dart';
import '../token/token.dart' as token;

Future<Response> getAccountBalance(Request request) async {
  Map<ResponseStatus, Map?> authUser =
      await token.validateToken(request.headers['Authorization']);
  if (authUser.keys.first != ResponseStatus.SUCCESS) {
    return Response(401, body: "Unauthorized");
  }

  Map userBody = authUser.values.first!;

  Map<ResponseStatus, double?> mapResponse =
      await Movement.getBalanceByUser(userBody["id"]);

  switch (mapResponse.keys.first) {
    case ResponseStatus.NO_WALLET:
      return Response.notFound('No wallet found');
    case ResponseStatus.SERVER_ERROR:
      return Response.internalServerError(body: 'Something went wrong');
    case ResponseStatus.NOT_FOUND:
      return Response.notFound('No results found for this wallet');
    default:
      return Response.ok(
          balanceResponseDTO(mapResponse.values.first!).toString());
  }
}
