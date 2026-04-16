import 'dart:io';
import 'dart:convert';
import 'dart:async';

class TemperatureServer {
  late ServerSocket serverSocket;
  final List<Socket> clients = [];

  Future<void> startServer() async {
    try {
      print('🌡️ Iniciando Servidor de Temperatura na porta 8080...');
      serverSocket = await ServerSocket.bind('127.0.0.1', 8080);
      print('✅ Servidor escutando em 127.0.0.1:8080');

      serverSocket.listen((Socket client) {
        handleClient(client);
      });

    } catch (e) {
      print('❌ Erro ao iniciar servidor: $e');
    }
  }

  void handleClient(Socket client) {
    print('🔗 Novo cliente conectado: ${client.remoteAddress.address}');
    clients.add(client);

    client.listen(
      (List<int> data) async {
        final message = utf8.decode(data).trim();
        
        try {
          // Processa cada linha JSON recebida
          final lines = message.split('\n');
          for (String line in lines) {
            if (line.trim().isNotEmpty) {
              final jsonData = jsonDecode(line);
              displayTemperature(jsonData);
              
              // Envia confirmação ao cliente
              client.write('✅ Temperatura ${jsonData['temperature']}°C recebida com sucesso!\n');
            }
          }
        } catch (e) {
          print('❌ Erro ao processar dados: $e');
          client.write('❌ Dados inválidos recebidos\n');
        }
      },
      onError: (error) {
        print('❌ Erro com cliente ${client.remoteAddress.address}: $error');
        clients.remove(client);
        client.destroy();
      },
      onDone: () {
        print('🔌 Cliente ${client.remoteAddress.address} desconectado');
        clients.remove(client);
        client.destroy();
      },
    );
  }

  void displayTemperature(Map<String, dynamic> data) {
    final deviceId = data['device_id'] ?? 'Desconhecido';
    final timestamp = data['timestamp'] ?? DateTime.now().toString();
    final temp = data['temperature'];
    final unit = data['unit'] ?? '°C';

    print('''
╔══════════════════════════════════════╗
║          📊 LEITURA DE TEMPERATURA   ║
╠══════════════════════════════════════╣
║ Dispositivo: $deviceId              ║
║ Temperatura: ${temp.toString()} $unit        ║
║ Timestamp:  ${DateTime.parse(timestamp).toString().substring(0, 19)} ║
╚══════════════════════════════════════╝
    ''');
  }

  void closeServer() {
    serverSocket.close();
    for (var client in clients) {
      client.destroy();
    }
    clients.clear();
    print('🔚 Servidor encerrado');
  }
}

void main() async {
  final server = TemperatureServer();
  
  // Inicia servidor
  await server.startServer();

  // Aguarda Ctrl+C para encerrar
  ProcessSignal.sigint.watch().first.then((_) {
    server.closeServer();
    exit(0);
  });
}