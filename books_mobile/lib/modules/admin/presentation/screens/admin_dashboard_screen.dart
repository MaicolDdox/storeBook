import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../shared/models/order_model.dart';
import '../../models/admin_dashboard_range.dart';
import '../../models/admin_metrics_data.dart';
import '../providers/admin_dashboard_controller.dart';
import 'admin_book_form_screen.dart';
import 'admin_order_detail_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final NumberFormat _currency = NumberFormat.currency(symbol: '\$');
  final DateFormat _dayLabelFormat = DateFormat('MM/dd');
  final DateFormat _dateTimeFormat = DateFormat('MMM d, HH:mm');

  int _touchedStatusIndex = -1;
  final Set<int> _openingBookIds = <int>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminDashboardControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminDashboardControllerProvider);
    final controller = ref.read(adminDashboardControllerProvider.notifier);
    final overview = state.overview;

    if (state.isLoading && overview == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (overview == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Unable to load dashboard data.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => controller.load(),
                icon: const Icon(Symbols.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.load(range: state.range),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;
          final isTablet = constraints.maxWidth >= 720;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _buildHeader(
                    state: state,
                    onRangeChanged: (range) => controller.load(range: range),
                  ),
                ),
              ),
              if (state.isRefreshing)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: _buildKpiGrid(overview, isTablet: isTablet),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _buildChartsSection(state, isWide: isWide),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: _buildDataSections(state, isWide: isWide),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader({
    required AdminDashboardState state,
    required ValueChanged<AdminDashboardRange> onRangeChanged,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 560;

            final rangeSelector = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<AdminDashboardRange>(
                segments: AdminDashboardRange.values
                    .map(
                      (range) => ButtonSegment<AdminDashboardRange>(
                        value: range,
                        label: Text(range.label),
                      ),
                    )
                    .toList(),
                selected: {state.range},
                onSelectionChanged: (selection) {
                  final selectedRange = selection.first;
                  if (selectedRange != state.range) {
                    onRangeChanged(selectedRange);
                  }
                },
              ),
            );

            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  rangeSelector,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                rangeSelector,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiGrid(
    AdminMetricsOverview overview, {
    required bool isTablet,
  }) {
    final cards = <_KpiCardData>[
      _KpiCardData(
        title: 'Total Books',
        value: overview.booksCount.toString(),
        icon: Symbols.menu_book,
      ),
      _KpiCardData(
        title: 'Total Categories',
        value: overview.categoriesCount.toString(),
        icon: Symbols.label,
      ),
      _KpiCardData(
        title: 'Total Orders',
        value: overview.ordersCount.toString(),
        icon: Symbols.receipt_long,
      ),
      _KpiCardData(
        title: 'Pending Orders',
        value: overview.pendingOrdersCount.toString(),
        icon: Symbols.pending_actions,
      ),
      _KpiCardData(
        title: 'Low Stock',
        value: overview.lowStockCount.toString(),
        icon: Symbols.warning,
      ),
      _KpiCardData(
        title: 'Paid Revenue',
        value: _currency.format(overview.paidRevenue),
        icon: Symbols.payments,
      ),
    ];

    final crossAxisCount = isTablet ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: cards.length,
      itemBuilder: (_, index) {
        final item = cards[index];
        return _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: const Color(0xFF00ABE4)),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  color: Color(0xFF445462),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: const TextStyle(
                  color: Color(0xFF08395A),
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartsSection(
    AdminDashboardState state, {
    required bool isWide,
  }) {
    final lineChartCard = _DashboardCard(
      child: _ChartSection(
        title: 'Orders Over Time',
        child: _buildOrdersLineChart(state.ordersSeries),
      ),
    );
    final pieChartCard = _DashboardCard(
      child: _ChartSection(
        title: 'Order Status Distribution',
        child: _buildOrderStatusChart(state.orderStatusMetrics),
      ),
    );
    final barChartCard = _DashboardCard(
      child: _ChartSection(
        title: 'Top Categories (Sold Items)',
        child: _buildTopCategoriesBarChart(state.topCategories),
      ),
    );

    if (isWide) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: lineChartCard),
              const SizedBox(width: 12),
              Expanded(child: pieChartCard),
            ],
          ),
          const SizedBox(height: 12),
          barChartCard,
        ],
      );
    }

    return Column(
      children: [
        lineChartCard,
        const SizedBox(height: 12),
        pieChartCard,
        const SizedBox(height: 12),
        barChartCard,
      ],
    );
  }

  Widget _buildDataSections(AdminDashboardState state, {required bool isWide}) {
    final recentOrdersCard = _DashboardCard(
      child: _DataSection(
        title: 'Recent Orders',
        child: _buildRecentOrders(state.recentOrders, isWide: isWide),
      ),
    );
    final lowStockCard = _DashboardCard(
      child: _DataSection(
        title: 'Low Stock Books',
        child: _buildLowStockBooks(state.lowStockBooks),
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: recentOrdersCard),
          const SizedBox(width: 12),
          Expanded(child: lowStockCard),
        ],
      );
    }

    return Column(
      children: [recentOrdersCard, const SizedBox(height: 12), lowStockCard],
    );
  }

  Widget _buildOrdersLineChart(List<AdminOrdersSeriesItem> points) {
    if (points.isEmpty) {
      return const _EmptyChartState(message: 'No order data for this range.');
    }

    final maxY = points
        .map((item) => item.orders.toDouble())
        .fold<double>(0, math.max);
    final yInterval = _yAxisInterval(maxY);
    final xInterval = _xAxisInterval(points.length);

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY <= 0 ? 1 : maxY * 1.25,
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final index = spot.x.toInt();
                  final item = points[index];
                  return LineTooltipItem(
                    '${_dayLabelFormat.format(item.date)}\n${item.orders} orders',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: yInterval,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Color(0xFF587086),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: xInterval,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % xInterval.toInt() != 0 &&
                      index != points.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _dayLabelFormat.format(points[index].date),
                      style: const TextStyle(
                        color: Color(0xFF587086),
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                points.length,
                (index) =>
                    FlSpot(index.toDouble(), points[index].orders.toDouble()),
              ),
              isCurved: true,
              color: const Color(0xFF00ABE4),
              barWidth: 3,
              dotData: FlDotData(show: points.length <= 14),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0x3300ABE4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusChart(List<AdminStatusMetric> items) {
    if (items.isEmpty) {
      return const _EmptyChartState(message: 'No status data for this range.');
    }

    const palette = [
      Color(0xFF00ABE4),
      Color(0xFF1BC47D),
      Color(0xFFF3A832),
      Color(0xFFEF5350),
      Color(0xFF7E57C2),
      Color(0xFF5C6BC0),
    ];

    final total = items.fold<int>(0, (sum, item) => sum + item.count);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 42,
              pieTouchData: PieTouchData(
                touchCallback: (_, response) {
                  setState(() {
                    _touchedStatusIndex =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: List.generate(items.length, (index) {
                final item = items[index];
                final touched = index == _touchedStatusIndex;
                final color = palette[index % palette.length];
                final percent = total == 0 ? 0 : (item.count / total) * 100;

                return PieChartSectionData(
                  color: color,
                  value: item.count.toDouble(),
                  radius: touched ? 68 : 60,
                  title: '${percent.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final color = palette[index % palette.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_toTitleCase(item.name)} (${item.count})',
                  style: const TextStyle(
                    color: Color(0xFF3F566A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTopCategoriesBarChart(List<AdminTopCategoryMetric> items) {
    if (items.isEmpty) {
      return const _EmptyChartState(message: 'No category sales data found.');
    }

    final topItems = items.take(8).toList();
    final maxY = topItems
        .map((item) => item.count.toDouble())
        .fold<double>(0, math.max);

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY <= 0 ? 1 : maxY * 1.25,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, __, ___) {
                final item = topItems[group.x.toInt()];
                return BarTooltipItem(
                  '${item.category}\n${item.count} sold items',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _yAxisInterval(maxY),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: _yAxisInterval(maxY),
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Color(0xFF587086),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= topItems.length) {
                    return const SizedBox.shrink();
                  }
                  final name = topItems[index].category;
                  final label = name.length <= 8
                      ? name
                      : '${name.substring(0, 8)}…';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF587086),
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(topItems.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: topItems[index].count.toDouble(),
                  width: 18,
                  color: const Color(0xFF00ABE4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(List<OrderModel> orders, {required bool isWide}) {
    if (orders.isEmpty) {
      return const _EmptyDataState(message: 'No recent orders available.');
    }

    if (isWide) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Order')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Created')),
          ],
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(Text('#${order.id}')),
                DataCell(Text(order.userEmail ?? 'Unknown customer')),
                DataCell(Text(_currency.format(order.total))),
                DataCell(_StatusBadge(status: order.status)),
                DataCell(
                  Text(
                    order.createdAt == null
                        ? '-'
                        : _dateTimeFormat.format(order.createdAt!.toLocal()),
                  ),
                ),
              ],
              onSelectChanged: (_) => _openOrderDetail(order.id),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      children: orders.map((order) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          leading: const Icon(Symbols.receipt_long, color: Color(0xFF00ABE4)),
          title: Text(
            'Order #${order.id}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${order.userEmail ?? 'Unknown customer'}\n${_currency.format(order.total)}',
          ),
          trailing: _StatusBadge(status: order.status),
          onTap: () => _openOrderDetail(order.id),
        );
      }).toList(),
    );
  }

  Widget _buildLowStockBooks(List<AdminLowStockItem> books) {
    if (books.isEmpty) {
      return const _EmptyDataState(message: 'No low stock books detected.');
    }

    return Column(
      children: books.map((book) {
        final isOpening = _openingBookIds.contains(book.id);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          leading: const Icon(Symbols.warning, color: Color(0xFFF3A832)),
          title: Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Stock: ${book.stockQuantity}   Price: ${_currency.format(book.price)}',
          ),
          trailing: isOpening
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Symbols.edit_square, color: Color(0xFF00ABE4)),
          onTap: isOpening ? null : () => _openBookEditor(book.id),
        );
      }).toList(),
    );
  }

  void _openOrderDetail(int orderId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminOrderDetailScreen(orderId: orderId),
      ),
    );
  }

  Future<void> _openBookEditor(int bookId) async {
    setState(() => _openingBookIds.add(bookId));

    try {
      final book = await ref.read(adminRepositoryProvider).fetchBook(bookId);
      if (!mounted) return;

      final updated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => AdminBookFormScreen(book: book)),
      );

      if (updated == true && mounted) {
        await ref
            .read(adminDashboardControllerProvider.notifier)
            .load(range: ref.read(adminDashboardControllerProvider).range);
      }
    } on ApiException catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(exception.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _openingBookIds.remove(bookId));
      }
    }
  }

  double _yAxisInterval(double maxY) {
    if (maxY <= 4) return 1;
    return (maxY / 4).ceilToDouble();
  }

  double _xAxisInterval(int length) {
    if (length <= 8) return 1;
    if (length <= 30) return 5;
    return 15;
  }

  String _toTitleCase(String raw) {
    final words = raw.split('_');
    return words
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14002A42),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _DataSection extends StatelessWidget {
  const _DataSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final background = switch (normalized) {
      'pending' => const Color(0x1AF3A832),
      'paid' => const Color(0x1A00ABE4),
      'processing' => const Color(0x1A7E57C2),
      'shipped' => const Color(0x1A00A38C),
      'completed' => const Color(0x1A1BC47D),
      'cancelled' => const Color(0x1AEF5350),
      _ => const Color(0x1A607D94),
    };
    final foreground = switch (normalized) {
      'pending' => const Color(0xFF915A00),
      'paid' => const Color(0xFF006D93),
      'processing' => const Color(0xFF5B3E8C),
      'shipped' => const Color(0xFF00786A),
      'completed' => const Color(0xFF0E8A58),
      'cancelled' => const Color(0xFFB3261E),
      _ => const Color(0xFF5D7588),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _KpiCardData {
  const _KpiCardData({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF607D94),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyDataState extends StatelessWidget {
  const _EmptyDataState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF607D94),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
