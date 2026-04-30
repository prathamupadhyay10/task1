import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_router.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/query/data/repositories/query_repository.dart';
import 'features/query/presentation/bloc/query_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/query/presentation/screens/user_dashboard.dart';
import 'features/query/presentation/screens/add_edit_query_screen.dart';
import 'features/query/presentation/screens/query_detail_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard.dart';
import 'features/admin/presentation/screens/admin_override_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PriorityResolverApp());
}

class PriorityResolverApp extends StatelessWidget {
  const PriorityResolverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepositoryImpl(),
          ),
        ),
        BlocProvider(
          create: (context) => QueryBloc(
            queryRepository: QueryRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Priority Resolver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRouter.splash,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.splash:
        return _pageRoute(const SplashScreen());
      case AppRouter.login:
        return _pageRoute(const LoginScreen());
      case AppRouter.signup:
        return _pageRoute(const SignupScreen());
      case AppRouter.userDashboard:
        return _pageRoute(const UserDashboard());
      case AppRouter.adminDashboard:
        return _pageRoute(const AdminDashboard());
      case AppRouter.addQuery:
        return _pageRoute(
          const AddEditQueryScreen(isEditing: false),
        );
      case AppRouter.editQuery:
        return _pageRoute(
          AddEditQueryScreen(
            isEditing: true,
            query: settings.arguments as dynamic,
          ),
        );
      case AppRouter.queryDetail:
        return _pageRoute(
          const QueryDetailScreen(),
          arguments: settings.arguments,
        );
      case AppRouter.adminOverride:
        return _pageRoute(const AdminOverridePanel());
      default:
        return _pageRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  PageRouteBuilder _pageRoute(Widget page, {Object? arguments}) {
    return PageRouteBuilder(
      settings: RouteSettings(name: page.runtimeType.toString(), arguments: arguments),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
