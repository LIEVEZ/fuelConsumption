enum DashboardPage { consumption, expense, energy, maintenance, mine }

enum DashboardTab { consumption, expense, energy, mine }

enum CreateRecordAction { energy, maintenance }

extension DashboardTabPage on DashboardTab {
  DashboardPage get page => switch (this) {
    DashboardTab.consumption => DashboardPage.consumption,
    DashboardTab.expense => DashboardPage.expense,
    DashboardTab.energy => DashboardPage.energy,
    DashboardTab.mine => DashboardPage.mine,
  };
}
