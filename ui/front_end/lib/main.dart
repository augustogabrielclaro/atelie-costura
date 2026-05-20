import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/pedido_provider.dart';

import 'ui/screens/home_screen.dart';
import 'ui/screens/cadastro_pedido_screen.dart';
import 'ui/screens/entregas_diarias_screen.dart';
import 'ui/screens/pecas_list_screen.dart';
import 'ui/screens/calendario_pedido_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR');

  runApp(const AtelieApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/cadastro-pedido',
      builder: (context, state) => CadastroPedidoScreen(),
    ),

    GoRoute(
      path: '/entregas-hoje',
      builder: (context, state) => const EntregasDiariasScreen(),
    ),

    GoRoute(
      path: '/pecas',
      builder: (context, state) => const PecasListScreen(),
    ),

    GoRoute(
      path: '/meu-calendario',
      builder: (context, state) => const CalendarioEventosPage(),
    ),
  ],
);

class AtelieApp extends StatelessWidget {
  const AtelieApp({super.key});

  @override
  Widget build(BuildContext context) {
    const roxo = Color(0xFF4A148C);

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PedidoProvider())],

      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        title: 'Ateliê Automático',

        theme: ThemeData(
          useMaterial3: true,

          colorScheme: ColorScheme.fromSeed(seedColor: roxo),

          scaffoldBackgroundColor: const Color(0xFFF4F2FF),

          fontFamily: 'Roboto',
        ),

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],

        locale: const Locale('pt', 'BR'),

        routerConfig: _router,
      ),
    );
  }
}
