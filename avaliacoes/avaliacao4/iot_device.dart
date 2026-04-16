import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:async';

class IoTSensor {
  static const String SERVER_HOST = '127.0.0.1';
  static const int SERVER_PORT = 8080;
  late Socket socket;
  late Timer timer;
  Random random = Random();

  Future<void> connectAndSend() async {
    try {
      print('🔥 IoT Sensor iniciando conexão com servidor $SERVER_HOST:$SERVER_PORT...');
      
      // Conecta ao servidor
      socket = await Socket.connect(SERVER_HOST, SERVER_PORT);
      print('✅ Conectado ao servidor!');

      // Inicia envio periódico de dados a cada 10 segundos
      timer = Timer.periodic(Duration(seconds: 10), (timer) {
        sendTemperature();
      });

      // Escuta respostas do servidor
      socket.listen(
        (data) {
          final message = utf8.decode(data).trim();
          print('📨 Resposta do servidor: $message');
        },
        onError: (error) {
          print('❌ Erro na comunicação: $error');
          timer.cancel();
          socket.destroy();
        },
        onDone: () {
          print('🔌 Conexão fechada pelo servidor');
          timer.cancel();
        },
      );

      // Envia primeira leitura imediatamente
      sendTemperature();

    } catch (e) {
      print('❌ Erro ao conectar: $e');
    }
  }

  void sendTemperature() {
    // Simula temperatura realista entre 15°C e 35°C
    double temperature = 25.0 + (random.nextDouble() - 0.5) * 20;
    temperature = double.parse(temperature.toStringAsFixed(2));

    final data = {
      'device_id': 'sensor_temp_001',
      'timestamp': DateTime.now().toIso8601String(),
      'temperature': temperature,
      'unit': '°C'
    };

    final jsonData = jsonEncode(data);
    
    socket.write('$jsonData\n');
    print('📤 Enviando: ${jsonData}');
  }

  void close() {
    timer?.cancel();
    socket.destroy();
    print('🔌 IoT Sensor desconectado');
  }
}

void main() async {
  final sensor = IoTSensor();
  
  // Aguarda Ctrl+C para encerrar
  ProcessSignal.sigint.watch().first.then((_) {
    sensor.close();
    exit(0);
  });

  await sensor.connectAndSend();
}