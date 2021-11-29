import 'package:shelf_router/shelf_router.dart';

import '../server/environment.dart';
import './balance.dart';
import './deposit.dart';
import './refund.dart';
import './withdraw.dart';
import './create_wallet.dart';


Router router = Configuration.getRouter();

void setRoutes(){

  router.add('GET', '/wallet/balance', getAccountBalance);
  router.add('POST', '/wallet/deposit', depositAmount);
  router.add('POST', '/wallet/withdraw', withdrawAmount);
  router.add('POST', '/wallet/refund', refundAmount);
  router.add('POST', '/wallet/create', createWallet);
}


