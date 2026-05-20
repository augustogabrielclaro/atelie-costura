import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/pedido_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/cadastro_pedido_screen.dart';
import 'ui/screens/entregas_diarias_screen.dart';
import 'ui/screens/pecas_list_screen.dart';
import 'ui/screens/calendario_pedido_screen.dart';

void main() {
  runApp(const AtelieApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',

  routes: [
    // HOME
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

    // CADASTRO PEDIDO
    GoRoute(
      path: '/cadastro-pedido',
      builder: (context, state) => CadastroPedidoScreen(),
    ),

    // ENTREGAS
    GoRoute(
      path: '/entregas-hoje',
      builder: (context, state) => const EntregasDiariasScreen(),
    ),

    // PEÇAS
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

// =========================
// APP
// =========================

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

        routerConfig: _router,
      ),
    );
  }
}

// Tela de Dashboard/Menu inicial (pode ser separada em ui/screens/home_screen.dart depois)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Ateliê'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Nova Encomenda'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: () => context.push('/cadastro-pedido'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Entregas do Dia'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: () => context.push('/entregas-hoje'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.checkroom),
              label: const Text('Todas as Peças'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: () => context.push('/pecas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: const Text('Calendario'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: () => context.push('/meu-calendario'),
            ),
          ],
        ),
      ),
    );
  }
}
