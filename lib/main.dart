import 'package:flutter/material.dart';
import 'home_page.dart'; // Importa la página de inicio desde el archivo separado

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialApp(
        title: 'Mis Finanzas',
        theme: ThemeData(
          primaryColor: Colors
              .deepPurple, // Cambia el color de la AppBar a morado eléctrico
          scaffoldBackgroundColor: Colors.black,
        ),
        home: FinanzasHomePage(), // Navega hacia la página de inicio
      ),
    );
  }
}
