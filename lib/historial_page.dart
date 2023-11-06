import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_page.dart';

class ResumenMensual {
  final String mes;
  final double ingresos;
  final double gastos;
  final double ahorro;

  ResumenMensual({
    required this.mes,
    required this.ingresos,
    required this.gastos,
    required this.ahorro,
  });
}

class ResumenAnual {
  final int ano;
  final List<ResumenMensual> resumenes;

  ResumenAnual({
    required this.ano,
    required this.resumenes,
  });
}

class ResumenMensualPage extends StatefulWidget {
  @override
  _ResumenMensualPageState createState() => _ResumenMensualPageState();
}

class _ResumenMensualPageState extends State<ResumenMensualPage> {
  List<RegistroFinanciero> registros = [];
  List<ResumenMensual> resumenes = [];
  List<ResumenAnual> resumenesAnuales = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    String registrosJson = prefs.getString('registros') ?? '';
    if (registrosJson.isNotEmpty) {
      List<dynamic> listaJson = jsonDecode(registrosJson);
      registros = listaJson.map((e) => RegistroFinanciero.fromJson(e)).toList();
      _calcularResumenMensual();

      setState(() {});
    }
  }

  _calcularResumenMensual() {
    var meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    var anos = registros.map((e) => e.fecha.year).toSet().toList();
    resumenesAnuales = [];

    for (var ano in anos) {
      List<ResumenMensual> resumenesTemp = [];

      var mesesConRegistros = registros
          .where((reg) => reg.fecha.year == ano)
          .map((e) => e.fecha.month)
          .toSet()
          .toList();

      for (var mesInt in mesesConRegistros) {
        var registrosMes = registros
            .where((reg) => reg.fecha.month == mesInt && reg.fecha.year == ano)
            .toList();

        double ingresosMes = registrosMes
            .where((reg) => reg.esIngreso)
            .fold(0.0, (sum, item) => sum + item.monto);

        double gastosMes = registrosMes
            .where((reg) => !reg.esIngreso)
            .fold(0.0, (sum, item) => sum + item.monto);

        double ahorroMes = ingresosMes - gastosMes;

        resumenesTemp.add(ResumenMensual(
          mes: meses[mesInt - 1],
          ingresos: ingresosMes,
          gastos: gastosMes,
          ahorro: ahorroMes,
        ));
      }

      if (resumenesTemp.isNotEmpty) {
        resumenesAnuales.add(ResumenAnual(ano: ano, resumenes: resumenesTemp));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (resumenesAnuales.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Resumen Anual y Mensual'),
            backgroundColor: Colors.deepPurple),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen Anual y Mensual'),
        backgroundColor: Colors.deepPurple, // Aquí se establece el color morado
      ),
      body: ListView.builder(
        itemCount: resumenesAnuales.length,
        itemBuilder: (context, index) {
          if (resumenesAnuales.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          final resumenAnual = resumenesAnuales[index];
          return Card(
            shape: RoundedRectangleBorder(
              // Agrega el diseño redondeado
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5, // Da una ligera sombra alrededor
            margin: EdgeInsets.all(10), // Margen entre cada Card
            child: Padding(
              padding: EdgeInsets.all(5), // Espacio interno para el contenido
              child: ExpansionTile(
                title: Text(
                  'Año: ${resumenAnual.ano}',
                  style: TextStyle(color: Colors.black),
                ),
                children: resumenAnual.resumenes.map((resumenMensual) {
                  return Card(
                    child: ListTile(
                      title: Text(resumenMensual.mes),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Ingresos: \$${resumenMensual.ingresos.toStringAsFixed(2)}'),
                          Text(
                              'Gastos: \$${resumenMensual.gastos.toStringAsFixed(2)}'),
                          Text(
                              'Ahorro: \$${resumenMensual.ahorro.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
