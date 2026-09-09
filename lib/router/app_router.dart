import 'package:go_router/go_router.dart';

import 'package:humanacare_paciente/models/app_state.dart';

import 'package:humanacare_paciente/screens/auth/login_screen.dart';
import 'package:humanacare_paciente/screens/auth/perfil_screen.dart';
import 'package:humanacare_paciente/screens/auth/register_screen.dart';

import 'package:humanacare_paciente/screens/paciente/paciente_home.dart';
import 'package:humanacare_paciente/screens/paciente/tabs/sos_screen.dart';
import 'package:humanacare_paciente/screens/paciente/editar_perfil_screen.dart';
import 'package:humanacare_paciente/screens/paciente/alertas_screen.dart';

import 'package:humanacare_paciente/screens/cuidador/cuidador_home.dart';
import 'package:humanacare_paciente/screens/familiar/familiar_home.dart';

class AppRouter {
  static GoRouter router(AppState appState) {
    return GoRouter(
      initialLocation: '/login',

      refreshListenable: appState,

      routes: [
        // LOGIN
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const LoginScreen(),
        ),

        // CADASTRO
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              const RegisterScreen(),
        ),

        // ESCOLHA DO PERFIL
        GoRoute(
          path: '/perfil',
          builder: (context, state) =>
              const PerfilScreen(),
        ),

        // =========================
        // PACIENTE
        // =========================
        GoRoute(
          path: '/paciente',
          builder: (context, state) =>
              const PacienteHome(),
        ),

        // =========================
        // CUIDADOR
        // =========================
        GoRoute(
          path: '/cuidador',
          builder: (context, state) =>
              const CuidadorHome(),
        ),

        // =========================
        // FAMILIAR
        // =========================
        GoRoute(
          path: '/familiar',
          builder: (context, state) =>
              const FamiliarHome(),
        ),

        // =========================
        // FUNCIONALIDADES PACIENTE
        // =========================

        GoRoute(
          path: '/sos',
          builder: (context, state) =>
              const SosScreen(),
        ),

        GoRoute(
          path: '/editar-perfil',
          builder: (context, state) =>
              const EditarPerfilScreen(),
        ),

        GoRoute(
          path: '/alertas',
          builder: (context, state) =>
              const AlertasScreen(),
        ),
      ],

      redirect: (context, state) {
        final loggedIn = appState.logado;

        final location = state.matchedLocation;

        final isLogin = location == '/login';

        final isRegister = location == '/register';

        final isPerfil = location == '/perfil';

        final isPaciente = location == '/paciente';

        final isCuidador = location == '/cuidador';

        final isFamiliar = location == '/familiar';

        // =====================================================
        // 1. USUÁRIO NÃO ESTÁ LOGADO
        // =====================================================

        if (!loggedIn) {
          if (isLogin || isRegister) {
            return null;
          }

          return '/login';
        }

        // =====================================================
        // 2. USUÁRIO ESTÁ LOGADO, MAS NÃO ESCOLHEU PERFIL
        // =====================================================

        if (appState.perfil.isEmpty) {
          if (isPerfil) {
            return null;
          }

          return '/perfil';
        }

        // =====================================================
        // 3. FAMILIAR/CUIDADOR PRECISAM DE VÍNCULO
        // =====================================================

        final precisaVinculo =
            appState.perfil == 'familiar' ||
            appState.perfil == 'cuidador';

        final semVinculo =
            appState.pacienteVinculadoId == null ||
            appState.pacienteVinculadoId!.isEmpty;

        if (precisaVinculo && semVinculo) {
          if (isPerfil) {
            return null;
          }

          return '/perfil';
        }

        // =====================================================
        // 4. PERFIL PACIENTE
        // =====================================================

        if (appState.perfil == 'paciente') {
          if (isPaciente) {
            return null;
          }

          // Impede paciente de cair na tela de cuidador/familiar.
          if (isCuidador || isFamiliar) {
            return '/paciente';
          }
        }

        // =====================================================
        // 5. PERFIL CUIDADOR
        // =====================================================

        if (appState.perfil == 'cuidador') {
          if (isCuidador) {
            return null;
          }

          // Impede cuidador de cair na tela do paciente
          // ou na tela do familiar.
          if (isPaciente || isFamiliar) {
            return '/cuidador';
          }
        }

        // =====================================================
        // 6. PERFIL FAMILIAR
        // =====================================================

        if (appState.perfil == 'familiar') {
          if (isFamiliar) {
            return null;
          }

          // Impede familiar de cair na tela do paciente
          // ou do cuidador.
          if (isPaciente || isCuidador) {
            return '/familiar';
          }
        }

        // =====================================================
        // 7. USUÁRIO JÁ ESTÁ CONFIGURADO
        // =====================================================

        if (isLogin || isRegister || isPerfil) {
          switch (appState.perfil) {
            case 'paciente':
              return '/paciente';

            case 'cuidador':
              return '/cuidador';

            case 'familiar':
              return '/familiar';
          }
        }

        return null;
      },
    );
  }
}