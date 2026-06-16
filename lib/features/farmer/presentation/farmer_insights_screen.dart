import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../deals/domain/deal.dart';
import '../../deals/presentation/deal_controller.dart';

class FarmerInsightsScreen extends ConsumerStatefulWidget {
  const FarmerInsightsScreen({super.key});

  @override
  ConsumerState<FarmerInsightsScreen> createState() =>
      _FarmerInsightsScreenState();
}

class _FarmerInsightsScreenState extends ConsumerState<FarmerInsightsScreen> {
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month);
    _to = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orders = ref.watch(farmerDealsProvider).valueOrNull ?? const <Deal>[];
    final report = _SalesReport.from(orders, _from, _to);
    final allTimeSales = orders
        .where((order) => order.status == DealStatus.completed)
        .fold<double>(0, (sum, order) => sum + order.quantity * order.price);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insightsTabLabel),
        actions: [
          IconButton(
            tooltip: l10n.salesStatementLabel,
            onPressed: report.completed.isEmpty
                ? null
                : () => _showStatement(report),
            icon: const Icon(Icons.description_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
        children: [
          _RangeSelector(
            label: _rangeLabel,
            onPreviousMonth: _previousMonth,
            onNextMonth: _canMoveNext ? _nextMonth : null,
            onCustomRange: _pickCustomRange,
          ),
          const SizedBox(height: 14),
          _SalesHero(report: report, allTimeSales: allTimeSales),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: l10n.completedOrdersLabel,
                  value: '${report.orderCount}',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: l10n.averageOrderLabel,
                  value: '€${report.averageOrder.toStringAsFixed(2)}',
                  icon: Icons.equalizer_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: l10n.quantitySoldLabel,
                  value: '${_format(report.kgSold)} kg',
                  icon: Icons.scale_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: l10n.declinedStatus,
                  value: '${report.declinedCount}',
                  icon: Icons.close_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SectionTitle(l10n.salesTrendTitle),
          const SizedBox(height: 10),
          _TrendCard(report: report),
          const SizedBox(height: 26),
          _SectionTitle(l10n.topProductsTitle),
          const SizedBox(height: 10),
          _ProductBars(products: report.products),
          const SizedBox(height: 26),
          _SectionTitle(l10n.fulfilmentTitle),
          const SizedBox(height: 10),
          _FulfilmentCard(
            pickupOrders: report.pickupOrders,
            courierOrders: report.courierOrders,
          ),
          const SizedBox(height: 26),
          _InsightCard(report: report),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: report.completed.isEmpty
                ? null
                : () => _showStatement(report),
            icon: const Icon(Icons.description_outlined),
            label: Text(l10n.viewSalesStatementLabel),
          ),
        ],
      ),
    );
  }

  String get _rangeLabel {
    final sameMonth = _from.year == _to.year && _from.month == _to.month;
    if (sameMonth && _from.day == 1 && _to.day >= 28) {
      return DateFormat('MMMM yyyy').format(_from);
    }
    return '${DateFormat('d MMM yyyy').format(_from)} – ${DateFormat('d MMM yyyy').format(_to)}';
  }

  bool get _canMoveNext {
    final now = DateTime.now();
    return _from.isBefore(DateTime(now.year, now.month));
  }

  void _previousMonth() {
    final month = DateTime(_from.year, _from.month - 1);
    setState(() {
      _from = month;
      _to = DateTime(
        month.year,
        month.month + 1,
      ).subtract(const Duration(days: 1));
    });
  }

  void _nextMonth() {
    final month = DateTime(_from.year, _from.month + 1);
    final now = DateTime.now();
    final monthEnd = DateTime(
      month.year,
      month.month + 1,
    ).subtract(const Duration(days: 1));
    setState(() {
      _from = month;
      _to = month.year == now.year && month.month == now.month
          ? DateTime(now.year, now.month, now.day)
          : monthEnd;
    });
  }

  Future<void> _pickCustomRange() async {
    final today = DateTime.now();
    final safeEnd = _to.isAfter(today)
        ? DateTime(today.year, today.month, today.day)
        : _to;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(today.year, today.month, today.day),
      initialDateRange: DateTimeRange(start: _from, end: safeEnd),
      helpText: AppLocalizations.of(context).salesPeriodLabel,
      saveText: AppLocalizations.of(context).showReportLabel,
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
    }
  }

  Future<void> _showStatement(_SalesReport report) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _StatementSheet(report: report, rangeLabel: _rangeLabel),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.label,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCustomRange,
  });

  final String label;
  final VoidCallback onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback onCustomRange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.previousMonthTooltip,
            onPressed: onPreviousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: InkWell(
              onTap: onCustomRange,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.customRangeHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.nextMonthTooltip,
            onPressed: onNextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _SalesHero extends StatelessWidget {
  const _SalesHero({required this.report, required this.allTimeSales});

  final _SalesReport report;
  final double allTimeSales;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF173F2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalSalesLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '€${report.revenue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            l10n.completedOrderCountLabel(report.orderCount),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'All-time sales',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Text(
                  '€${allTimeSales.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2F6B45), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.report});

  final _SalesReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.bucketDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: report.trend.every((value) => value == 0)
                ? Center(child: Text(l10n.noCompletedSalesMessage))
                : CustomPaint(
                    size: const Size(double.infinity, 150),
                    painter: _TrendPainter(report.trend),
                  ),
          ),
          if (!report.trend.every((value) => value == 0)) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: report.trendLabels
                  .map(
                    (label) => Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE2E7E1)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final maxValue = math.max(1.0, values.reduce(math.max));
    final path = Path();
    final pointPaint = Paint()..color = const Color(0xFF2F6B45);
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = size.height - (values[i] / maxValue * (size.height - 18)) - 9;
      final point = Offset(x, y);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      canvas.drawCircle(point, 4, pointPaint);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2F6B45)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _ProductBars extends StatelessWidget {
  const _ProductBars({required this.products});

  final List<_ProductStats> products;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (products.isEmpty) {
      return _EmptyCard(l10n.noProductSalesMessage);
    }
    final visible = products.take(5).toList();
    final maxRevenue = visible.map((item) => item.revenue).reduce(math.max);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: visible.map((product) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name.split(' / ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('€${product.revenue.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 7),
                LinearProgressIndicator(
                  value: maxRevenue == 0 ? 0 : product.revenue / maxRevenue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(99),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.soldQuantityLabel(
                    _format(product.quantity),
                    product.unit,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FulfilmentCard extends StatelessWidget {
  const _FulfilmentCard({
    required this.pickupOrders,
    required this.courierOrders,
  });

  final int pickupOrders;
  final int courierOrders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = pickupOrders + courierOrders;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: total == 0
          ? Text(l10n.noCompletedOrdersMessage)
          : Row(
              children: [
                SizedBox.square(
                  dimension: 112,
                  child: CustomPaint(
                    painter: _DonutPainter(pickup: pickupOrders / total),
                    child: Center(
                      child: Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _LegendRow(
                        color: const Color(0xFF2F6B45),
                        label: l10n.farmPickupLabel,
                        value: '$pickupOrders',
                      ),
                      const SizedBox(height: 14),
                      _LegendRow(
                        color: const Color(0xFF86A990),
                        label: l10n.courierLabel,
                        value: '$courierOrders',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.pickup});

  final double pickup;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    paint.color = const Color(0xFF86A990);
    canvas.drawArc(rect.deflate(10), -math.pi / 2, math.pi * 2, false, paint);
    paint.color = const Color(0xFF2F6B45);
    canvas.drawArc(
      rect.deflate(10),
      -math.pi / 2,
      math.pi * 2 * pickup,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.pickup != pickup;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.report});

  final _SalesReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final product = report.products.firstOrNull;
    final message = product == null
        ? l10n.insightEmptyMessage
        : l10n.topEarningProductMessage(product.name.split(' / ').first);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBDD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatementSheet extends StatelessWidget {
  const _StatementSheet({required this.report, required this.rangeLabel});

  final _SalesReport report;
  final String rangeLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = report.completedGroups;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.salesStatementLabel,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(rangeLabel),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.shareReportTooltip,
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: report.statementText(rangeLabel)),
                    ),
                    icon: const Icon(Icons.ios_share_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: groups.length,
                separatorBuilder: (_, __) => const Divider(height: 22),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final first = group.first;
                  final total = group.fold<double>(
                    0,
                    (sum, item) =>
                        sum + item.quantity * item.price + item.deliveryFee,
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 62,
                        child: Text(
                          DateFormat(
                            'd MMM',
                          ).format(first.completedAt ?? first.createdAt),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${first.orderGroupId.split('-').last}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              group
                                  .map(
                                    (item) =>
                                        '${item.title.split(' / ').first} ${_format(item.quantity)} ${item.unit}',
                                  )
                                  .join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              first.fulfillmentMethod ==
                                      FulfillmentMethod.farmPickup
                                  ? l10n.farmPickupLabel
                                  : l10n.courierLabel,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '€${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesReport {
  _SalesReport({
    required this.from,
    required this.to,
    required this.completed,
    required this.completedGroups,
    required this.products,
    required this.revenue,
    required this.orderCount,
    required this.kgSold,
    required this.declinedCount,
    required this.pickupOrders,
    required this.courierOrders,
    required this.trend,
    required this.trendLabels,
    required this.bucketDescription,
  });

  final DateTime from;
  final DateTime to;
  final List<Deal> completed;
  final List<List<Deal>> completedGroups;
  final List<_ProductStats> products;
  final double revenue;
  final int orderCount;
  final double kgSold;
  final int declinedCount;
  final int pickupOrders;
  final int courierOrders;
  final List<double> trend;
  final List<String> trendLabels;
  final String bucketDescription;

  double get averageOrder => orderCount == 0 ? 0 : revenue / orderCount;

  factory _SalesReport.from(List<Deal> orders, DateTime from, DateTime to) {
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    bool inRange(DateTime date) => !date.isBefore(from) && !date.isAfter(end);
    final completed = orders.where((order) {
      if (order.status != DealStatus.completed) return false;
      return inRange(order.completedAt ?? order.createdAt);
    }).toList();
    final declined = orders.where((order) {
      return order.status == DealStatus.cancelled && inRange(order.createdAt);
    });
    final grouped = <String, List<Deal>>{};
    for (final order in completed) {
      grouped.putIfAbsent(order.orderGroupId, () => []).add(order);
    }
    final groups = grouped.values.toList()
      ..sort(
        (a, b) => (b.first.completedAt ?? b.first.createdAt).compareTo(
          a.first.completedAt ?? a.first.createdAt,
        ),
      );
    final productMap = <String, _ProductStats>{};
    for (final order in completed) {
      final stats = productMap.putIfAbsent(
        order.productId,
        () => _ProductStats(order.title, order.unit),
      );
      stats.quantity += order.quantity;
      stats.revenue += order.quantity * order.price;
    }
    final products = productMap.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    final revenue = completed.fold<double>(
      0,
      (sum, order) => sum + order.quantity * order.price,
    );
    final kgSold = completed
        .where((order) => order.unit == 'kg')
        .fold<double>(0, (sum, order) => sum + order.quantity);
    final pickup = groups
        .where(
          (group) =>
              group.first.fulfillmentMethod == FulfillmentMethod.farmPickup,
        )
        .length;
    final trendData = _buildTrend(completed, from, end);
    return _SalesReport(
      from: from,
      to: end,
      completed: completed,
      completedGroups: groups,
      products: products,
      revenue: revenue,
      orderCount: groups.length,
      kgSold: kgSold,
      declinedCount: declined.map((item) => item.orderGroupId).toSet().length,
      pickupOrders: pickup,
      courierOrders: groups.length - pickup,
      trend: trendData.values,
      trendLabels: trendData.labels,
      bucketDescription: trendData.description,
    );
  }

  String statementText(String rangeLabel) {
    final buffer = StringBuffer()
      ..writeln('FreshFarm sales statement')
      ..writeln(rangeLabel)
      ..writeln('Total sales: €${revenue.toStringAsFixed(2)}')
      ..writeln('Completed orders: $orderCount')
      ..writeln();
    for (final group in completedGroups) {
      final first = group.first;
      final total = group.fold<double>(
        0,
        (sum, item) => sum + item.quantity * item.price + item.deliveryFee,
      );
      buffer.writeln(
        '${DateFormat('yyyy-MM-dd').format(first.completedAt ?? first.createdAt)} | ${first.orderGroupId} | ${group.map((item) => item.title.split(' / ').first).join(', ')} | €${total.toStringAsFixed(2)}',
      );
    }
    return buffer.toString();
  }
}

class _TrendData {
  const _TrendData(this.values, this.labels, this.description);
  final List<double> values;
  final List<String> labels;
  final String description;
}

_TrendData _buildTrend(List<Deal> orders, DateTime from, DateTime to) {
  final days = to.difference(from).inDays + 1;
  final bucketCount = days <= 31
      ? math.min(days, 7)
      : days <= 183
      ? 6
      : 12;
  final bucketDays = math.max(1, (days / bucketCount).ceil());
  final values = List<double>.filled(bucketCount, 0);
  for (final order in orders) {
    final date = order.completedAt ?? order.createdAt;
    final index = math.min(
      bucketCount - 1,
      date.difference(from).inDays ~/ bucketDays,
    );
    values[index] += order.quantity * order.price;
  }
  final labels = List.generate(bucketCount, (index) {
    final date = from.add(Duration(days: index * bucketDays));
    if (days > 183) return DateFormat('MMM').format(date);
    if (days > 31) return '${index + 1}';
    return DateFormat('d MMM').format(date);
  });
  final description = days <= 31
      ? 'Sales across this period'
      : days <= 183
      ? 'Weekly sales'
      : 'Monthly sales';
  return _TrendData(values, labels, description);
}

class _ProductStats {
  _ProductStats(this.name, this.unit);
  final String name;
  final String unit;
  double quantity = 0;
  double revenue = 0;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(message),
  );
}

String _format(double value) => value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
