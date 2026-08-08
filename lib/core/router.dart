import "package:go_router/go_router.dart";

import "../features/home/home_screen.dart";
import "../features/join/join_screen.dart";
import "../shared/widgets/page_not_found.dart";

class MeetCafeRouter {
  static final GoRouter config = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: "/join/:id",
        builder: (context, state) =>
            JoinScreen(meetingId: state.pathParameters["id"]!),
      ),
    ],
    errorBuilder: (context, state) => const PageNotFound(),
  );
}

