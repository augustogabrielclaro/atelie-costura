import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import '../../providers/whatsapp_provider.dart';

class ConfiguracaoWhatsappScreen extends StatefulWidget {
  const ConfiguracaoWhatsappScreen({super.key});

  @override
  State<ConfiguracaoWhatsappScreen> createState() => _ConfiguracaoWhatsappScreenState();
}

class _ConfiguracaoWhatsappScreenState extends State<ConfiguracaoWhatsappScreen> {
  static const roxo = Color(0xFF4A148C);
  
  final _formKey = GlobalKey<FormState>();
  final _telefoneIdController = TextEditingController();
  final _wabaIdController = TextEditingController();
  final _tokenController = TextEditingController();

  bool _isLoading = false;

  final _idFormatter = MaskTextInputFormatter(
    mask: '####################', 
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    // 1. Ativa o loading na tela
    setState(() => _isLoading = true);

    final provider = context.read<WhatsappProvider>();
    await provider.carregarConfiguracao();
    
    if (provider.configAtual != null) {
      _telefoneIdController.text = provider.configAtual!.telefoneId;
      _wabaIdController.text = provider.configAtual!.wabaId ?? '';
    }
    
    // 2. Desativa o loading
    setState(() => _isLoading = false);
  }

  Future<void> _salvar() async {
    // Se a validação falhar (campos vazios), ele para aqui e mostra os textos em vermelho
    if (!_formKey.currentState!.validate()) return;

    // 1. Oculta o formulário e mostra a bolinha rodando
    setState(() => _isLoading = true);

    final provider = context.read<WhatsappProvider>();
    
    final sucesso = await provider.salvarConfiguracao(
      telefoneId: _telefoneIdController.text,
      token: _tokenController.text,
      wabaId: _wabaIdController.text.isEmpty ? null : _wabaIdController.text,
    );

    // 2. Volta a mostrar o formulário
    setState(() => _isLoading = false);

    // 3. Mostra o resultado (Verde se ok, Vermelho se falhou)
    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salvo com sucesso!'), 
          backgroundColor: Colors.green
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Erro de conexão com a API'), 
          backgroundColor: Colors.red
        ),
      );
    }  
  }

  @override
  void dispose() {
    _telefoneIdController.dispose();
    _wabaIdController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final possuiToken = context.read<WhatsappProvider>().configAtual?.possuiToken ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),
      appBar: AppBar(
        backgroundColor: roxo,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Configuração Meta API', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: roxo))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200)
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Insira a Identificação do número de telefone gerada no painel da Meta, e não o número com DDD.',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildTextField(
                    label: 'ID do Número de Telefone *',
                    controller: _telefoneIdController,
                    formatter: _idFormatter,
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    label: 'WABA ID (Opcional)',
                    controller: _wabaIdController,
                    formatter: _idFormatter,
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    label: possuiToken ? 'Token de Acesso Permanente (Configurado)' : 'Token de Acesso Permanente *',
                    controller: _tokenController,
                    isObscure: false,
                    hintText: possuiToken ? '••••••••••••••••' : null,
                    helperText: possuiToken 
                      ? 'Deixe em branco para manter o atual. Cole um novo para alterar.' 
                      : 'Cole o token gerado no painel da Meta.',
                    validator: (val) {
                      if (!possuiToken && (val == null || val.isEmpty)) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: roxo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar Configurações',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    MaskTextInputFormatter? formatter,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isObscure = false,
    String? helperText,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: formatter != null ? [formatter] : [],
      keyboardType: keyboardType,
      validator: validator,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: roxo, width: 2),
        ),
      ),
    );
  }
}