import 'package:flutter/material.dart';
import 'package:hobby_reads_flutter/screens/admin/add_hobby_screen.dart';
import 'package:hobby_reads_flutter/screens/admin/admin_dashboard_screen.dart';
import 'package:hobby_reads_flutter/screens/admin/hobbies_screen.dart';
import 'package:hobby_reads_flutter/screens/admin/users_screen.dart';
import 'package:hobby_reads_flutter/screens/auth/login_screen.dart';
import 'package:hobby_reads_flutter/screens/auth/register_screen.dart';
import 'package:hobby_reads_flutter/screens/books/add_book_screen.dart';
import 'package:hobby_reads_flutter/screens/books/book_detail_screen.dart';
import 'package:hobby_reads_flutter/screens/books/books_screen.dart';
import 'package:hobby_reads_flutter/screens/connections/connections_screen.dart';
import 'package:hobby_reads_flutter/screens/home/home_screen.dart';
import 'package:hobby_reads_flutter/screens/landing/landing_screen.dart';
import 'package:hobby_reads_flutter/screens/profile/profile_screen.dart';
import 'package:hobby_reads_flutter/screens/trades/trade_requests_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      
      // Auth Routes
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      // Main App Routes
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/books':
        return MaterialPageRoute(builder: (_) => const BooksScreen());
      case '/add-book':
        return MaterialPageRoute(builder: (_) => const AddBookScreen());
      case '/book-detail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookDetailScreen(
            bookId: args['bookId'] as int,
            book: args['book'],
          ),
        );
      
      // Connection Routes
      case '/connections':
        return MaterialPageRoute(builder: (_) => const ConnectionsScreen());
      
      // Profile Routes
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      // Trade Routes
      case '/trades':
        return MaterialPageRoute(builder: (_) => const TradeRequestsScreen());
      
      // Admin Routes
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/admin/users':
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());
      case '/admin/hobbies':
        return MaterialPageRoute(builder: (_) => const AdminHobbiesScreen());
      case '/admin/hobbies/add':
        return MaterialPageRoute(builder: (_) => const AddHobbyScreen());
      
      // Default Route
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper method to navigate to a named route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Helper method to navigate and replace current route
  static Future<T?> navigateToReplacement<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Helper method to navigate and clear all previous routes
  static Future<T?> navigateToAndClear<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
} 