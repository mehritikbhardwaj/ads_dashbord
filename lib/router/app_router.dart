import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_dependencies.dart';
import '../features/alerts/bloc/anomaly_alerts_bloc.dart';
import '../features/alerts/view/anomaly_alerts_page.dart';
import '../features/campaigns/bloc/campaign_detail_cubit.dart';
import '../features/campaigns/bloc/campaign_list_cubit.dart';
import '../features/campaigns/view/campaign_detail_page.dart';
import '../features/campaigns/view/campaign_list_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/spend/bloc/spend_summary_cubit.dart';
import '../features/spend/view/spend_summary_page.dart';
import '../services/notification_service.dart';
import '../widgets/main_shell.dart';

/// Declarative routing with a persistent tab shell (go_router).
GoRouter createAppRouter({
  required AppDependencies deps,
  required NotificationService notifications,
}) {
  return GoRouter(
    initialLocation: '/campaigns',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/campaigns',
                builder: (context, state) => BlocProvider(
                  create: (_) {
                    final cubit = CampaignListCubit(deps.campaigns);
                    cubit.refresh();
                    return cubit;
                  },
                  child: const CampaignListPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'detail/:campaignId',
                    builder: (context, state) {
                      final id = state.pathParameters['campaignId']!;
                      return BlocProvider(
                        create: (_) =>
                            CampaignDetailCubit(deps.campaigns)..load(id),
                        child: CampaignDetailPage(campaignId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/spend',
                builder: (context, state) => BlocProvider(
                  create: (_) {
                    final c = SpendSummaryCubit(deps.summary);
                    c.load();
                    return c;
                  },
                  child: const SpendSummaryPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => BlocProvider(
                  create: (_) => AnomalyAlertsBloc(deps.anomalies, notifications)
                    ..add(const AnomalyAlertsStarted()),
                  child: const AnomalyAlertsPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
