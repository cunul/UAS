import 'package:intl/intl.dart';

String formatPrice(int price) {
  return NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
      .format(price * 15145);
}

enum OrderStatus {
  PENDING,
  ON_PROCESS,
  ON_DELIVERY,
  DELIVERED,
  COMPLETE,
}

int defineOrderStatus(OrderStatus status) {
  switch (status) {
    case OrderStatus.PENDING:
      return 0;
    case OrderStatus.ON_PROCESS:
      return 1;
    case OrderStatus.ON_DELIVERY:
      return 2;
    case OrderStatus.DELIVERED:
      return 3;
    case OrderStatus.COMPLETE:
      return 4;
    default:
      return 0;
  }
}

String defineOrderStatusName(int statusCode) {
  switch (statusCode) {
    case 0:
      return 'Menunggu Pembayaran';
    case 1:
      return 'Diproses';
    case 2:
      return 'Dalam Pengiriman';
    case 3:
      return 'Sudah Terkirim';
    case 4:
      return 'Selesai';
    default:
      return 'Menunggu Pembayaran';
  }
}
