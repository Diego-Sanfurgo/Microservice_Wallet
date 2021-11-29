import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:mysql1/mysql1.dart';
import 'package:mysql_utils/mysql_utils.dart';

import '../routes/routes.dart';

abstract class Configuration {
  static late final MySqlConnection? _dbConnection;
  static final Router _router = Router();

  static void init() async {
    _initServer(_router);
    _dbConnection = await _initDB();
    setRoutes();
  }

  static Future<MySqlConnection> getDB(
      {String? host,
      int? port,
      String? user,
      String? dbName,
      String? pass}) async {
    _dbConnection ??= await _connectDB(host, port, user, dbName, pass);

    return _dbConnection!;
  }

  static Future<MySqlConnection> getDefaultDB() async {
    _dbConnection ??= await _connectDBDefault();
    return _dbConnection!;
  }

  static Router getRouter() {
    return _router;
  }
}

Future<MySqlConnection> _connectDB(String? host, int? port, String? user,
    String? dbName, String? password) async {
  try {
    final MySqlConnection conn = await MySqlConnection.connect(
        ConnectionSettings(
            host: host ?? 'localhost',
            port: port ?? 3306,
            user: user ?? 'root',
            db: dbName ?? 'wallet_service',
            password: password ?? '123456'));

    print("Conexión creada");
    return conn;
  } on MySqlException catch (ex, stacktrace) {
    print("¡APA LA PAPA! ¡Hubo un error al conectar a MySQL!");
    print(stacktrace);

    rethrow;
  }
}

//Connects with DB without asking for any parameters
Future<MySqlConnection> _connectDBDefault() async {
  try {
    final MySqlConnection conn = await MySqlConnection.connect(
        ConnectionSettings(
            host: 'localhost',
            port: 3306,
            user: 'root',
            db: 'wallet_service',
            password: '123456'));

    print("Conexión creada");

    return conn;
  } on MySqlException catch (ex, stacktrace) {
    print("¡APA LA PAPA! ¡Hubo un error al conectar a MySQL!");
    print(stacktrace);

    rethrow;
  }
}

void _initServer(Router routerHandler) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final _handler =
      Pipeline().addMiddleware(logRequests()).addHandler(routerHandler);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(_handler, ip, port);
  print('Server listening on port ${server.port}');
}

Future<MySqlConnection> _initDB() async {
  return await _connectDBDefault();
}
