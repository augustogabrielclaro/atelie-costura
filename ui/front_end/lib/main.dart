import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Providers
import 'providers/pedido_provider.dart';

// Screens
import 'ui/screens/cadastro_pedido_screen.dart';
import 'ui/screens/entregas_diarias_screen.dart';

void main() {
  runApp(const AtelieApp());
}

// Configuração de Rotas com GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/cadastro-pedido',
      builder: (context, state) => CadastroPedidoScreen(),
    ),
    GoRoute(
      path: '/entregas-hoje',
      builder: (context, state) => const EntregasDiariasScreen(),
    ),
  ],
);

class AtelieApp extends StatelessWidget {
  const AtelieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Injeção do estado global. Adicione os próximos Providers aqui.
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
      ],
      child: MaterialApp.router(
        title: 'Ateliê Automático',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () => context.push('/cadastro-pedido'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Entregas do Dia'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () => context.push('/entregas-hoje'),
            ),
          ],
        ),
      ),
    );
  }
}