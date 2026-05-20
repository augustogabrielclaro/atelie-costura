import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const roxo = Color(0xFF4A148C);
  static const roxoEscuro = Color(0xFF2A0A4A);
  static const verdeAgua = Color(0xFF64FFDA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: roxo,
        title: const Text(
          'Painel do Ateliê',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F2FF), Color(0xFFE7DDFD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(24),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 20),

                const Text(
                  'Bem-vinda',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: roxoEscuro,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Gerencie suas encomendas de forma rápida e organizada',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 40),

                // NOVA ENCOMENDA
                _menuCard(
                  context,
                  icon: Icons.add_box_rounded,
                  title: 'Nova Encomenda',
                  description: 'Cadastre uma nova peça e organize os pedidos.',
                  route: '/cadastro-pedido',
                ),

                const SizedBox(height: 22),

                // ENTREGAS
                _menuCard(
                  context,
                  icon: Icons.local_shipping_rounded,
                  title: 'Entregas do Dia',
                  description:
                      'Visualize as encomendas com entrega programada.',
                  route: '/entregas-hoje',
                ),

                const SizedBox(height: 22),

                // PEÇAS
                _menuCard(
                  context,
                  icon: Icons.checkroom_rounded,
                  title: 'Todas as Peças',
                  description: 'Veja todas as peças cadastradas.',
                  route: '/pecas',
                ),

                const SizedBox(height: 22),

                // CALENDÁRIO
                _menuCard(
                  context,
                  icon: Icons.calendar_month_rounded,
                  title: 'Calendário',
                  description: 'Organize os pedidos por data.',
                  route: '/meu-calendario',
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.push(route),

      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: roxo.withOpacity(0.10),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(22),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: verdeAgua.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(icon, color: roxo, size: 32),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: roxoEscuro,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      description,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: roxo,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
