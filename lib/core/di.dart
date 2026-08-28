import 'api/api_client.dart';
import 'api/token_store.dart';
import 'auth/auth_controller.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/users/data/users_repository.dart';
import '../features/games/data/games_repository.dart';
import '../features/rewards/data/rewards_repository.dart';
import '../features/tournaments/data/tournaments_repository.dart';
import '../features/notifications/data/notifications_repository.dart';
import '../features/content/data/banners_repository.dart';

/// Lightweight service locator: lazily-initialised top-level singletons.
/// Pages import these directly (matches the app's existing no-DI-framework
/// style). [tokenStore] must be `init()`-ed before use — see `main.dart`.

final TokenStore tokenStore = TokenStore();
final ApiClient apiClient = ApiClient(tokenStore);

final AuthRepository authRepository = AuthRepository(apiClient);
final AuthController authController = AuthController(authRepository, tokenStore, apiClient);

final DashboardRepository dashboardRepository = DashboardRepository(apiClient);
final UsersRepository usersRepository = UsersRepository(apiClient);
final GamesRepository gamesRepository = GamesRepository(apiClient);
final RewardsRepository rewardsRepository = RewardsRepository(apiClient);
final TournamentsRepository tournamentsRepository = TournamentsRepository(apiClient);
final NotificationsRepository notificationsRepository = NotificationsRepository(apiClient);
final BannersRepository bannersRepository = BannersRepository(apiClient);
