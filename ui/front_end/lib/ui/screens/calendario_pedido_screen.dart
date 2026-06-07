import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/all_peca.dart';
import '../../services/peca_service.dart';

class CalendarioPedidoScreen extends StatefulWidget {
  const CalendarioPedidoScreen({super.key});

  @override
  State<CalendarioPedidoScreen> createState() => _CalendarioPedidoScreenState();
}

class _CalendarioPedidoScreenState extends State<CalendarioPedidoScreen> {
  final PecaService _service = PecaService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<AllPeca> eventosDoDia = [];
  bool isLoading = false;
  Map<DateTime, List<AllPeca>> eventosMapeados = {};

  // =========================
  // CORES
  // =========================
  static const roxo = Color(0xFF4A148C);
  static const roxoEscuro = Color(0xFF2A0A4A);
  static const verdeAgua = Color(0xFF64FFDA);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _buscarTodosOsEventos();
  }

  // Normaliza a data para ignorar horas/minutos/segundos e garantir o match no mapa
  DateTime _normalizarData(DateTime data) {
    return DateTime.utc(data.year, data.month, data.day);
  }

  // Busca todos os eventos e os agrupa por data
  Future<void> _buscarTodosOsEventos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final todasAsPecas = await _service.listarTodasPecas();

      Map<DateTime, List<AllPeca>> mapaTemporario = {};

      for (var peca in todasAsPecas) {
        // Converte a string 'YYYY-MM-DD' do banco para DateTime
        DateTime dataPeca = DateTime.parse(peca.dataEntrega);
        DateTime dataChave = _normalizarData(dataPeca);

        if (mapaTemporario[dataChave] == null) {
          mapaTemporario[dataChave] = [];
        }
        mapaTemporario[dataChave]!.add(peca);
      }

      setState(() {
        eventosMapeados = mapaTemporario;
        eventosDoDia = eventosMapeados[_normalizarData(_focusedDay)] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Erro ao carregar eventos: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: roxo,
        title: const Text(
          'Calendário de Pedidos',
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
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
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
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                locale: 'pt_BR',
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: roxo,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: roxo),
                  rightChevronIcon: Icon(Icons.chevron_right, color: roxo),
                  titleTextStyle: TextStyle(
                    color: roxoEscuro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: roxoEscuro, fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: roxo,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  selectedDecoration: BoxDecoration(
                    color: verdeAgua, // Verde água
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: roxoEscuro,
                    fontWeight: FontWeight.bold,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFE7DDFD), // Roxo clarinho
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: roxo,
                    fontWeight: FontWeight.bold,
                  ),
                  outsideDaysVisible: false,
                ),
                eventLoader: (day) {
                  return eventosMapeados[_normalizarData(day)] ?? [];
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      eventosDoDia =
                          eventosMapeados[_normalizarData(selectedDay)] ?? [];
                    });
                  }
                },
                // Permite mudar a visualização (Mês, Quinzena, Semana)
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: _construirListaDeEventos()),
          ],
        ),
      ),
    );
  }

  Widget _construirListaDeEventos() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: verdeAgua));
    }

    if (eventosDoDia.isEmpty) {
      return RefreshIndicator(
        color: roxo,
        onRefresh: _buscarTodosOsEventos,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            Icon(Icons.event_busy_outlined, size: 80, color: roxo),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Nenhum evento encontrado para este dia.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: roxoEscuro,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: roxo,
      onRefresh: _buscarTodosOsEventos,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: eventosDoDia.length,
        itemBuilder: (context, index) {
          final peca = eventosDoDia[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 6,
              shadowColor: roxo.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // DESCRIÇÃO
                    // =========================
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: verdeAgua.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.checkroom, color: roxo),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            peca.descricao,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: roxoEscuro,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // =========================
                    // CLIENTE
                    // =========================
                    Row(
                      children: [
                        const Icon(Icons.person, color: roxo, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            peca.clienteNome,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // =========================
                    // ENTREGA
                    // =========================
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: roxo, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          peca.dataEntrega,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // =========================
                    // VALOR
                    // =========================
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: verdeAgua.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'R\$ ${peca.valor.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: roxoEscuro,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
