import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/perfil_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/paciente/paciente_home.dart';
import '../screens/paciente/tabs/sos_screen.dart';
import '../screens/paciente/editar_perfil_screen.dart';
import '../screens/paciente/alertas_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/perfil',
        builder: (_, __) => const PerfilScreen(),
      ),

      GoRoute(
        path: '/paciente',
        builder: (_, __) => const PacienteHome(),
      ),

      GoRoute(
        path: '/sos',
        builder: (_, __) => const SosScreen(),
      ),
      GoRoute(
        path: '/editar-perfil',
        builder: (_, __) => const EditarPerfilScreen(),
      ),
      GoRoute(
        path: '/alertas',
        builder: (_, __) => const AlertasScreen(),
      ),
    ],

    redirect: (context, state) {
      final appState = Provider.of<AppState>(
        context,
        listen: false,
      );

      final loggedIn = appState.logado;
      final location = state.matchedLocation;

      // Rotas que podem ser acessadas sem estar logado
      final rotasPublicas = {
        '/login',
        '/register',
        '/perfil',
      };

      // Se não estiver logado e tentar acessar uma rota protegida
      if (!loggedIn && !rotasPublicas.contains(location)) {
        return '/login';
      }

      // Se estiver logado e tentar voltar para login
      if (loggedIn && location == '/login') {
        return '/paciente';
      }

      return null;
    },
  );

  static GoRouter router() => _router;
}

