import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../models/wallet/wallet.dart';
import '../server/flow_response.dart';

Future<Response> createWallet(Request req) async {
  String rawBody = await req.readAsString();

  Map body = jsonDecode(rawBody);

  ResponseStatus res = await Wallet.createWallet(body['userId']);

  switch (res) {
    case ResponseStatus.ALREADY_EXISTS:
      return Response.forbidden('This user already has a wallet created');
    case ResponseStatus.SUCCESS:
      return Response.ok('New wallet created');
    case ResponseStatus.SERVER_ERROR:
      return Response.internalServerError(
          body: 'Something went wrong, internal server error');
    default:
      return Response.notFound('This resource could not be found');
  }
}
