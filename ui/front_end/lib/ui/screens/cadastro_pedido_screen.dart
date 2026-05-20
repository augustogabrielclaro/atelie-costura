import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../../providers/pedido_provider.dart';

class CadastroPedidoScreen extends StatelessWidget {
  CadastroPedidoScreen({super.key});

  // =========================
  // CONTROLLERS
  // =========================

  final _telefoneController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();

  // =========================
  // MÁSCARAS
  // =========================

  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _dataMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _valorMask = MoneyInputFormatter(
    leadingSymbol: 'R\$ ',
    thousandSeparator: ThousandSeparator.Period,
    mantissaLength: 2,
  );

  // =========================
  // CONVERTER DATA
  // =========================

  String formatarData(String dataBR) {
    final partes = dataBR.split('/');
    return '${partes[2]}-${partes[1]}-${partes[0]}';
  }

  // =========================
  // CONVERTER VALOR
  // =========================

  double converterValor(String valor) {
    if (valor.isEmpty) return 0;

    String valorLimpo = valor.replaceAll('.', '').replaceAll(',', '.');

    return double.tryParse(valorLimpo) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidoProvider>();

    // =========================
    // CORES
    // =========================

    const roxo = Color(0xFF4A148C);
    const roxoEscuro = Color(0xFF2A0A4A);
    const verdeAgua = Color(0xFF64FFDA);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),

      // =========================
      // APPBAR
      // =========================
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: roxo,
        title: const Text(
          'Nova Encomenda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F2FF), Color(0xFFE7DDFD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Card(
              elevation: 10,
              shadowColor: roxo.withOpacity(0.25),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),

              child: Padding(
                padding: const EdgeInsets.all(24),

                child: ListView(
                  shrinkWrap: true,

                  children: [
                    // =========================
                    // TÍTULO
                    // =========================
                    const Text(
                      'Cadastrar Pedido',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: roxoEscuro,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Preencha os dados da encomenda',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // TELEFONE
                    // =========================
                    _buildTextField(
                      controller: _telefoneController,
                      label: 'Telefone do Cliente',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_telefoneMask],
                      onChanged: (val) => provider.verificarTelefone(val),
                    ),

                    const SizedBox(height: 18),

                    // =========================
                    // NOME
                    // =========================
                    _buildTextField(
                      controller: provider.nomeController,
                      label: 'Nome do Cliente',
                      icon: Icons.person,
                      enabled: !provider.isNomeBloqueado,

                      suffix: provider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 18),

                    // =========================
                    // DESCRIÇÃO
                    // =========================
                    _buildTextField(
                      controller: _descricaoController,
                      label: 'Descrição do Serviço',
                      icon: Icons.design_services,
                    ),

                    const SizedBox(height: 18),

                    // =========================
                    // VALOR
                    // =========================
                    _buildTextField(
                      controller: _valorController,
                      label: 'Valor (R\$)',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // =========================
                    // DATA
                    // =========================
                    _buildTextField(
                      controller: _dataController,
                      label: 'Data de Entrega',
                      icon: Icons.calendar_month,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_dataMask],
                    ),

                    const SizedBox(height: 35),

                    // =========================
                    // BOTÃO
                    // =========================
                    SizedBox(
                      height: 58,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roxo,
                          foregroundColor: Colors.white,

                          elevation: 6,

                          shadowColor: roxo.withOpacity(0.4),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        onPressed: () async {
                          final dataFormatada = formatarData(
                            _dataController.text,
                          );

                          final valorConvertido = converterValor(
                            _valorController.text,
                          );

                          await context.read<PedidoProvider>().salvarPedido(
                            _telefoneController.text,
                            _descricaoController.text,
                            valorConvertido,
                            dataFormatada,
                          );

                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: verdeAgua,
                              content: Text(
                                'Encomenda salva com sucesso!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          'Salvar Encomenda',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // WIDGET INPUT
  // =========================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,

    List<TextInputFormatter>? inputFormatters,

    TextInputType? keyboardType,

    bool enabled = true,

    Widget? suffix,

    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon, color: const Color(0xFF4A148C)),

        suffixIcon: suffix,

        filled: true,
        fillColor: Colors.grey.shade100,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF64FFDA), width: 2),
        ),
      ),
    );
  }
}
