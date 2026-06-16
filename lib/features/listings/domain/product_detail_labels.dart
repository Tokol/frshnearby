class ProductDetailLabels {
  const ProductDetailLabels({
    required this.method,
    required this.date,
    required this.pastDate,
    required this.futureDate,
    required this.showBestBefore,
    required this.showStorage,
  });

  final String method;
  final String date;
  final String pastDate;
  final String futureDate;
  final bool showBestBefore;
  final bool showStorage;
}

ProductDetailLabels productDetailLabels(String categoryId) {
  return const ProductDetailLabels(
    method: 'Production details (optional)',
    date: 'Produced date (optional)',
    pastDate: 'Produced',
    futureDate: 'Production expected',
    showBestBefore: true,
    showStorage: true,
  );
}
