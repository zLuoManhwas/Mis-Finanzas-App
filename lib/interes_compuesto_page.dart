import 'package:flutter/material.dart';
import 'dart:math';

class InteresCompuestoPage extends StatefulWidget {
  @override
  _InteresCompuestoPageState createState() => _InteresCompuestoPageState();
}

class _InteresCompuestoPageState extends State<InteresCompuestoPage> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _timeController = TextEditingController();
  final _nController =
      TextEditingController(); // número de veces que se compone el interés al año

  double _result = 0.0;

  _calculateInterest() {
    double principal = double.parse(_principalController.text);
    double rate = double.parse(_rateController.text) / 100;
    int time = int.parse(_timeController.text);
    int n = int.parse(_nController.text);

    _result = principal * pow((1 + (rate / n)), n * time);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interés Compuesto'),
        backgroundColor: Colors.black, // Fondo negro
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _principalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Principal (monto inicial)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.white, // Texto blanco
                ),
                hintStyle: TextStyle(
                  color: Colors.white, // Texto blanco
                ),
              ),
              style: TextStyle(
                  color: Colors
                      .white), // ¡Aquí cambias el color del texto que escribes!
            ),
            SizedBox(height: 16),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tasa de interés (%)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.white, // Texto blanco
                ),
                hintStyle: TextStyle(
                  color: Colors.white, // Texto blanco
                ),
              ),
              style: TextStyle(
                  color: Colors
                      .white), // ¡Aquí cambias el color del texto que escribes!
            ),
            SizedBox(height: 16),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tiempo (años)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.white, // Texto blanco
                ),
                hintStyle: TextStyle(
                  color: Colors.white, // Texto blanco
                ),
              ),
              style: TextStyle(
                  color: Colors
                      .white), // ¡Aquí cambias el color del texto que escribes!
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de veces al año',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.white, // Texto blanco
                ),
                hintStyle: TextStyle(
                  color: Colors.white, // Texto blanco
                ),
              ),
              style: TextStyle(
                  color: Colors
                      .white), // ¡Aquí cambias el color del texto que escribes!
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Calcular'),
              onPressed: _calculateInterest,
              style: ElevatedButton.styleFrom(
                primary: Colors.purple, // Morado eléctrico
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Resultado: $_result',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texto blanco
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black, // Fondo negro
    );
  }
}
