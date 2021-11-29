import 'package:intl/intl.dart';

import '../movement/movement.dart';

DateFormat formatDate = DateFormat('yyyy-MM-dd hh:mm:ss');

Map<String, dynamic> movementResponseDTO(Movement move, double actualAmount) {
  String amountName = move.amount > 0 ? "depositedAmount" : "withdrawedAmount";
  Map<String, dynamic> movementDTO = {
    "movement": {
      "actionStatus": stateToString(move.movementStateId),
      "actionName": actionToString(move.movementTypeId),
      amountName: move.amount.toString(),
      "description": move.description ?? "",
      "dateOfAction": formatDate.format(DateTime.parse(move.date)).toString()
    },
    "totalAmount": actualAmount.toString()
  };

  if (move.relatedMovementId != null) {
    movementDTO["movement"]
        .addAll({"relatedMovementID": move.relatedMovementId.toString()});
  }

  return movementDTO;
}

Map<String, String> balanceResponseDTO(double amount) {
  return {"ActualWalletAmount": amount.toString()};
}

String stateToString(int stateId) {
  switch (stateId) {
    case 0:
      return "Completed";
    case 1:
      return "Failed";
    case 2:
      return "Waiting";
    case 3:
      return "Cancelled";
    default:
      return "Error. Can't identify state";
  }
}

String actionToString(int actionId) {
  switch (actionId) {
    case 0:
      return "Deposit";
    case 1:
      return "Withdrawal";
    case 2:
      return "Refund";
    default:
      return "Error. Can't identify action";
  }
}
