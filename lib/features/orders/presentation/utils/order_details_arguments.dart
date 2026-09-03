class OrderDetailsArguments {
  final int orderId;
  final bool isAdmin;
  final bool focusDocuments;

  const OrderDetailsArguments({
    required this.orderId,
    this.isAdmin = false,
    this.focusDocuments = false,
  });
}
