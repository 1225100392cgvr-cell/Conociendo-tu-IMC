// Práctica 2 · Conociendo tu IMC
// Alumno: Cristopher Gerardo Villanueva Ramirez · Grupo GTID244
// Aplicación de una sola pantalla: captura nombre, peso (kg) y estatura (cm),
// calcula el IMC, lo clasifica y muestra el resultado en un diálogo y en una etiqueta.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ImcApp());

class ImcApp extends StatelessWidget {
  const ImcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conociendo tu IMC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PantallaImc(),
    );
  }
}

// ---------------------------------------------------------------------------
// Lógica del IMC (funciones puras, fáciles de probar)
// ---------------------------------------------------------------------------

/// Aplica IMC = peso / (estatura en metros)^2 y redondea a un decimal.
/// [estaturaCm] llega en centímetros; se convierte a metros dividiendo entre 100.
double calcularImc(double pesoKg, double estaturaCm) {
  final double estaturaM = estaturaCm / 100;
  final double imc = pesoKg / (estaturaM * estaturaM);
  // toStringAsFixed devuelve String, por eso se convierte de nuevo a double.
  return double.parse(imc.toStringAsFixed(1));
}

/// Clasifica el IMC ya redondeado con los límites 18.5, 25 y 30.
String obtenerCategoria(double imc) {
  if (imc < 18.5) {
    return 'Bajo peso';
  } else if (imc < 25) {
    return 'Peso normal';
  } else if (imc < 30) {
    return 'Sobrepeso';
  } else {
    return 'Obesidad';
  }
}

/// Mensaje de orientación según la categoría.
String obtenerConsejo(String categoria) {
  switch (categoria) {
    case 'Bajo peso':
      return 'Te recomendamos mejorar tu alimentación.';
    case 'Peso normal':
      return '¡Sigue así, vas muy bien!';
    case 'Sobrepeso':
      return 'Te conviene cuidar tu alimentación y actividad física.';
    default:
      return 'Es importante buscar orientación profesional.';
  }
}

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class PantallaImc extends StatefulWidget {
  const PantallaImc({super.key});

  @override
  State<PantallaImc> createState() => _PantallaImcState();
}

class _PantallaImcState extends State<PantallaImc> {
  // Un controlador por cada TextField.
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _estaturaCtrl = TextEditingController();

  // Texto que se muestra en la etiqueta de resultado.
  String _resultado = '';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _pesoCtrl.dispose();
    _estaturaCtrl.dispose();
    super.dispose();
  }

  /// Abre un AlertDialog reutilizable con un título y un mensaje.
  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Lee los datos, valida, calcula el IMC, clasifica y arma el mensaje.
  void _calcular() {
    final String nombre = _nombreCtrl.text.trim();
    final String textoPeso = _pesoCtrl.text.trim();
    final String textoEstatura = _estaturaCtrl.text.trim();

    // R9: validar que no falte ningún dato.
    if (nombre.isEmpty || textoPeso.isEmpty || textoEstatura.isEmpty) {
      _mostrarDialogo(
        'Datos incompletos',
        'Por favor captura tu nombre, tu peso y tu estatura.',
      );
      return;
    }

    // R9: validar que peso y estatura sean números válidos y mayores a cero.
    final double? peso = double.tryParse(textoPeso);
    final double? estatura = double.tryParse(textoEstatura);
    if (peso == null || estatura == null || peso <= 0 || estatura <= 0) {
      _mostrarDialogo(
        'Datos no válidos',
        'El peso y la estatura deben ser números mayores a cero.',
      );
      return;
    }

    // Cálculo, clasificación y mensaje (se clasifica el IMC ya redondeado).
    final double imc = calcularImc(peso, estatura);
    final String categoria = obtenerCategoria(imc);
    final String consejo = obtenerConsejo(categoria);

    final String mensaje = 'Hola, $nombre.\n'
        'Tu IMC es $imc.\n'
        'Tu estatus es: $categoria.\n'
        '$consejo';

    // R6: mismo mensaje en la etiqueta (setState) y en el diálogo.
    setState(() => _resultado = mensaje);
    _mostrarDialogo('Resultado', mensaje);
  }

  /// R7: vacía los controladores y la etiqueta.
  void _limpiar() {
    _nombreCtrl.clear();
    _pesoCtrl.clear();
    _estaturaCtrl.clear();
    setState(() => _resultado = '');
  }

  /// R8: cierra la aplicación.
  void _salir() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conociendo tu IMC'), // R1
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre: teclado de texto, cada palabra inicia con mayúscula.
            TextField(
              controller: _nombreCtrl,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Peso: teclado decimal, un punto y hasta dos decimales.
            TextField(
              controller: _pesoCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
            ),
            const SizedBox(height: 16),

            // Estatura: teclado numérico, solo dígitos enteros.
            TextField(
              controller: _estaturaCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Estatura (cm)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _calcular,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Calcular IMC'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _limpiar,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Limpiar datos'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _salir,
              child: const Text('Salir'),
            ),
            const SizedBox(height: 24),

            // Etiqueta de resultado (Container + Text).
            Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(minHeight: 80),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                border: Border.all(color: Colors.teal, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _resultado,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El IMC es una referencia general para personas adultas; '
              'no es un diagnóstico médico.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
