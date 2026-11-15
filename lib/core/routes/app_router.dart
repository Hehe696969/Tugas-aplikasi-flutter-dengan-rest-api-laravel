import 'package:flutter/material.dart';

import '../../views/auth/splash_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/books/books_view.dart';
import '../../views/books/book_detail_view.dart';
import '../../views/profile/profile_view.dart';
import '../../models/book_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String books = '/books';
  static const String bookDetail = '/book-detail';
  static const String profile = '/profile';
}

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash: (context) => const SplashView(),
  AppRoutes.login: (context) => const LoginView(),
  AppRoutes.register: (context) => const RegisterView(),
  AppRoutes.books: (context) => const BooksView(),
  AppRoutes.profile: (context) => const ProfileView(),
  AppRoutes.bookDetail: (context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;

    final book = args['book'] as BookModel;

    return BookDetailView(
      book: book,
      onEdit: args['onEdit'] as VoidCallback,
      onDelete: args['onDelete'] as VoidCallback,
    );
  },
};

void redirectToLogin() {
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    AppRoutes.login,
    (_) => false,
  );
}
