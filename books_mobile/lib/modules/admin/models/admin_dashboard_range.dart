enum AdminDashboardRange {
  sevenDays('7d', 'Last 7 days'),
  thirtyDays('30d', 'Last 30 days'),
  ninetyDays('90d', 'Last 90 days');

  const AdminDashboardRange(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
