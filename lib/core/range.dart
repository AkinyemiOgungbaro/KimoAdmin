/// UI period labels used by the dashboard/games dropdowns, mapped to the API's
/// `range` query tokens in one place.
///
/// The backend samples observed: dashboard `today`, games `30d`. Adjust the
/// tokens here if the backend expects different values.
enum RangePeriod { today, week, month }

extension RangePeriodX on RangePeriod {
  String get label => switch (this) {
        RangePeriod.today => 'Today',
        RangePeriod.week => 'This Week',
        RangePeriod.month => 'This Month',
      };

  String get token => switch (this) {
        RangePeriod.today => 'today',
        RangePeriod.week => '7d',
        RangePeriod.month => '30d',
      };
}

const kRangePeriods = RangePeriod.values;
