import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/artists/views/artist_detail_view.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/authentication/views/login_view.dart';
import 'package:hidi/features/authentication/views/sign_up_view.dart';
import 'package:hidi/features/daily-song/views/song_detail_view.dart';
import 'package:hidi/features/main-screen/views/main_navigation_view.dart';
import 'package:hidi/features/posts/views/post_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/${MainNavigationView.initialTab}',

    redirect: (context, state) {
      final isLoggIned = ref.read(authRepo).isLoggedIn;
      log("isLoggIned :$isLoggIned");

      if (!isLoggIned) {
        if (state.matchedLocation != SignUpView.routeURL &&
            state.matchedLocation != LoginView.routeURL) {
          return LoginView.routeURL;
        }
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: LoginView.routeURL,
        name: LoginView.routeName,
        builder: (context, state) {
          return LoginView();
        },
      ),
      GoRoute(
        path: SignUpView.routeURL,
        name: SignUpView.routeName,
        builder: (context, state) {
          return SignUpView();
        },
      ),
      GoRoute(
        path: "/:tab(daily-song|calendar|artists|search|mypage)",
        name: MainNavigationView.routeName,
        builder: (context, state) {
          final String tab = state.pathParameters["tab"]!;
          return MainNavigationView(tab: tab);
        },
      ),
      GoRoute(
        path: ArtistDetailView.routeURL,
        name: ArtistDetailView.routeName,
        builder: (context, state) {
          final String artistId = state.pathParameters["artistId"]!;
          return ArtistDetailView(artistId: int.parse(artistId));
        },
      ),
      GoRoute(
        path: SongDetailView.routeURL,
        name: SongDetailView.routeName,
        builder: (context, state) {
          final String songId = state.pathParameters["songId"]!;
          return SongDetailView(songId: int.parse(songId));
        },
      ),
      GoRoute(
        path: PostView.routeURL,
        name: PostView.routeName,
        builder: (context, state) {
          final String postId = state.pathParameters["postId"]!;
          return PostView(postId: int.parse(postId));
        },
      ),
    ],
  );
});
