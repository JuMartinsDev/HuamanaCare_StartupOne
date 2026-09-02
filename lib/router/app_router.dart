import 'package:go_router/go_router.dart';

import '../models/app_state.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/perfil_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/paciente/paciente_home.dart';
import '../screens/paciente/tabs/sos_screen.dart';
import '../screens/paciente/editar_perfil_screen.dart';
import '../screens/paciente/alertas_screen.dart';

class AppRouter {
  static GoRouter router(AppState appState) {
    return GoRouter(
      initialLocation: '/login',

      refreshListenable: appState,

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
        final loggedIn = appState.logado;
        final location = state.matchedLocation;

        final isLogin = location == '/login';
        final isRegister = location == '/register';
        final isPerfil = location == '/perfil';

        // -----------------------------------------
        // 1. Usuário NÃO autenticado
        // -----------------------------------------
        if (!loggedIn) {
          if (isLogin || isRegister) {
            return null;
          }

          return '/login';
        }

        // -----------------------------------------
        // 2. Usuário autenticado, mas ainda
        // não escolheu o perfil
        // -----------------------------------------
        if (appState.perfil.isEmpty) {
          if (isPerfil) {
            return null;
          }

          return '/perfil';
        }

        // -----------------------------------------
        // 3. Usuário autenticado e com perfil
        // -----------------------------------------

        // Não faz sentido voltar para login/cadastro
        if (isLogin || isRegister || isPerfil) {
          return '/paciente';
        }

        return null;
      },
    );
  }
}