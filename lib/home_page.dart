// home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'historial_page.dart';
import 'calculadora_page.dart';
import 'interes_compuesto_page.dart';

class RegistroFinanciero {
  final bool esIngreso;
  final double monto;
  final String descripcion;
  DateTime fecha;

  RegistroFinanciero({
    required this.esIngreso,
    required this.monto,
    required this.descripcion,
    required this.fecha, // Nuevo campo
  });

  RegistroFinanciero.fromJson(Map<String, dynamic> json)
      : esIngreso = json['esIngreso'],
        monto = json['monto'],
        descripcion = json['descripcion'],
        fecha = DateTime.parse(json['fecha']);

  Map<String, dynamic> toJson() => {
        'esIngreso': esIngreso,
        'monto': monto,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
      };
}

class FinanzasHomePage extends StatefulWidget {
  @override
  _FinanzasHomePageState createState() => _FinanzasHomePageState();
}

class _FinanzasHomePageState extends State<FinanzasHomePage> {
  double ingresos = 0.0;
  double gastos = 0.0;
  double ahorro = 0.0;
  String fechaSeleccionada = "Selecciona una fecha";
  List<RegistroFinanciero> registros = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      List<RegistroFinanciero> registrosTemp =
          listaJson.map((e) => RegistroFinanciero.fromJson(e)).toList();

      // Filtramos para obtener registros del mes actual
      DateTime now = DateTime.now();
      registrosTemp = registrosTemp.where((reg) {
        return reg.fecha.month == now.month && reg.fecha.year == now.year;
      }).toList();

      // Calcular ingresos, gastos y ahorros basados en la lista
      double ingresosTemp = registrosTemp
          .where((reg) => reg.esIngreso)
          .fold(0.0, (sum, item) => sum + item.monto);
      double gastosTemp = registrosTemp
          .where((reg) => !reg.esIngreso)
          .fold(0.0, (sum, item) => sum + item.monto);
      double ahorroTemp = ingresosTemp - gastosTemp;

      setState(() {
        registros = registrosTemp;
        ingresos = ingresosTemp;
        gastos = gastosTemp;
        ahorro = ahorroTemp;
      });
    }
  }

  _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    String registrosJson =
        jsonEncode(registros.map((e) => e.toJson()).toList());
    prefs.setString('registros', registrosJson);
  }

  void _agregarRegistro(bool esIngreso, double monto, String descripcion) {
    setState(() {
      if (monto > 0) {
        if (esIngreso) {
          ingresos += monto;
        } else {
          gastos += monto;
        }
        ahorro = ingresos - gastos;
        registros.add(RegistroFinanciero(
          esIngreso: esIngreso,
          monto: monto,
          descripcion: descripcion,
          fecha: DateTime.now(), // Usar la fecha actual aquí
        ));
        _guardarDatos(); // Llamamos solo este método para guardar todos los datos
      }
    });
  }

  FloatingActionButton _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el modal
                    _mostrarDialogoAgregarRegistro(
                        true); // Mostrar diálogo para agregar ingreso
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple, // Cambiar el color del botón
                  ),
                  child: Text(
                    "Agregar Ingreso",
                    style: TextStyle(color: Colors.white), // Color del texto
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el modal
                    _mostrarDialogoAgregarRegistro(
                        false); // Mostrar diálogo para agregar gasto
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple, // Cambiar el color del botón
                  ),
                  child: Text(
                    "Agregar Gasto",
                    style: TextStyle(color: Colors.white), // Color del texto
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.deepPurple, // Aquí cambias el color del FAB
    );
  }

  void _mostrarDialogoAgregarRegistro(bool esIngreso) {
    double monto = 0.0;
    String descripcion = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            esIngreso ? 'Agregar Ingreso' : 'Agregar Gasto',
            style: TextStyle(color: Colors.deepPurple), // Color del título
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  monto = double.parse(value);
                },
                decoration: InputDecoration(
                  hintText: 'Introduce el monto',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                onChanged: (value) {
                  descripcion = value;
                },
                decoration: InputDecoration(
                  hintText: 'Introduce una descripción',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.deepPurple), // Color del texto
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Agregar',
                style: TextStyle(color: Colors.deepPurple), // Color del texto
              ),
              onPressed: () {
                _agregarRegistro(esIngreso, monto, descripcion);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Container _buildBalanceContainer(String label, double amount) {
    return Container(
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.deepPurple, // Color del borde
          width: 2.0, // Ancho del borde
        ),
        borderRadius: BorderRadius.circular(10.0), // Borde redondeado
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  ListView _buildRegistroFinancieroList() {
    DateTime now = DateTime.now();
    List<RegistroFinanciero> registrosDelMesActual =
        registros.where((registro) {
      return registro.fecha.month == now.month &&
          registro.fecha.year == now.year;
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: registrosDelMesActual.length,
      itemBuilder: (context, index) {
        final registro = registrosDelMesActual[index];
        final tipo = registro.esIngreso ? 'Ingreso' : 'Gasto';
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          child: ListTile(
            leading: Text(
              registro.esIngreso
                  ? '+\$${registro.monto.toStringAsFixed(2)}'
                  : '-\$${registro.monto.toStringAsFixed(2)}',
              style: TextStyle(
                color: registro.esIngreso ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            title: Text(
              '$tipo: ${registro.descripcion} - Fecha: ${registro.fecha.toIso8601String()}',
              style: TextStyle(
                color: Colors.white, // Color del texto
              ),
            ),
          ),
        );
      },
    );
  }

  Container _buildGastosContainer(double gastosTotales) {
    return Container(
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.deepPurple, // Color del borde
          width: 2.0, // Ancho del borde
        ),
        borderRadius: BorderRadius.circular(10.0), // Borde redondeado
      ),
      child: Column(
        children: [
          Text(
            "Gastos:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "\$${gastosTotales.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double gastosTotales = gastos; // Calcular los gastos totales aquí

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Mi Finanzas"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBalanceContainer("Ingresos:", ingresos),
              ),
              Expanded(
                child: _buildGastosContainer(gastosTotales),
              ),
              Expanded(
                child: _buildBalanceContainer("Restante:", ahorro),
              ),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Stack(
              children: [
                Text(
                  "Registros Financieros de este mes:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  //textAlign: TextAlign.left, // Centra el texto
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 2.0,
                    color: Colors.deepPurple, // Línea morada
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildRegistroFinancieroList(),
          ),
        ],
      ),
      drawer: _crearDrawer(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Drawer _crearDrawer() {
    return Drawer(
      child: Container(
        // Agregamos el color de fondo
        color: Colors.black,
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                      20.0), // Redondea la esquina inferior izquierda
                  bottomRight: Radius.circular(
                      20.0), // Redondea la esquina inferior derecha
                ),
              ),
            ),
            _crearItem('Historial', ResumenMensualPage()),
            Divider(color: Colors.grey), // Separador
            _crearItem('Calculadora', CalculadoraPage()),
            Divider(color: Colors.grey), // Separador
            _crearItem(
                'Calculadora de interes compuesto', InteresCompuestoPage()),
            // Puedes agregar más pestañas aquí
          ],
        ),
      ),
    );
  }

  Widget _crearItem(String titulo, Widget paginaDestino) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => paginaDestino),
        );
      },
      borderRadius:
          BorderRadius.circular(15.0), // Bordado redondeado al presionar
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0), // Bordado redondeado
        ),
        child: ListTile(
          title: Text(titulo, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
