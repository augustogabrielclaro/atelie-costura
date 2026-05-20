import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:intl/date_symbol_data_local.dart';
import 'package:front_end/models/all_peca.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Mudança aqui: inicializa explicitamente o pt_BR
//   await initializeDateFormatting('pt_BR', 'null');
  
//   runApp(const CalendarioPedidoScreen());
// }


class CalendarioPedidoScreen extends StatelessWidget {
  const CalendarioPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' Meu Calendario',
      theme: ThemeData(primarySwatch: Colors.blue),
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('pt', 'BR'), // Define o Português do Brasil
      // ],

      home: const CalendarioEventosPage(),
    );
  }
}

class CalendarioEventosPage extends StatefulWidget {
  const CalendarioEventosPage({super.key});

  @override
  State<CalendarioEventosPage> createState() => _StartPageState();
}

class _StartPageState extends State<CalendarioEventosPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<AllPeca> eventosDoDia = []; // Lista que vai guardar as peças/eventos
  bool isLoading = false;
  Map<DateTime, List<AllPeca>> eventosMapeados = {};

  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Busca TODOS os eventos ao abrir a tela
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
      // Usando a rota que retorna todas as peças (baseado no seu PecaService)
      final response = await _dio.get('/pecas/all');

      List<AllPeca> todasAsPecas = (response.data as List)
          .map((p) => AllPeca.fromJson(p))
          .toList();

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
        // Já carrega os eventos do dia atual caso existam
        eventosDoDia = eventosMapeados[_normalizarData(_focusedDay)] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Calendario')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            // locale: 'pt_BR',

            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Color(0xFF4A148C),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,

              selectedDecoration: BoxDecoration(
                color: Color(0xFF64FFDA), // Verde água
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),

              todayDecoration: BoxDecoration(
                color: Color(0xFFE7DDFD), // Roxo clarinho
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Color(0xFF4A148C),
                fontWeight: FontWeight.bold,
              ),
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

          const SizedBox(height: 20),

          // Lista de eventos (placeholder)
          Expanded(child: _construirListaDeEventos()),
        ],
      ),
    );
  }

  Widget _construirListaDeEventos() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Se o Python respondeu, mas a lista veio vazia
    if (eventosDoDia.isEmpty) {
      return const Center(child: Text('Nenhum evento encontrado.'));
    }

    // 4. Se deu tudo certo e temos dados!
    return ListView.builder(
      itemCount: eventosDoDia.length,
      itemBuilder: (context, index) {
        final peca = eventosDoDia[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.event, color: Colors.blue),
            title: Text(
              peca.descricao,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Cliente: ${peca.clienteNome}'),
            trailing: Text(
              'R\$ ${peca.valor.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
