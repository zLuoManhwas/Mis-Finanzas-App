import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class CalculadoraPage extends StatefulWidget {
  @override
  _CalculadoraPageState createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  String _output = "0";
  String _expression = "";
  double num1 = 0.0;
  double num2 = 0.0;
  String operand = "";
  bool isAdvanced = false;

  buttonPressed(String buttonText) {
    if (buttonText == "C") {
      _output = "0";
      num1 = 0.0;
      num2 = 0.0;
      operand = "";
      _expression = "";
    } else if (buttonText == "+" ||
        buttonText == "-" ||
        buttonText == "/" ||
        buttonText == "X" ||
        buttonText == "%") {
      num1 = double.parse(_output);
      operand = buttonText;
      _output = "0";
      _expression = "$num1 $operand ";
    } else if (buttonText == "=") {
      num2 = double.parse(_output);

      switch (operand) {
        case "+":
          _output = (num1 + num2).toString();
          break;
        case "-":
          _output = (num1 - num2).toString();
          break;
        case "X":
          _output = (num1 * num2).toString();
          break;
        case "/":
          _output = (num1 / num2).toString();
          break;
        case "%":
          _output = (num1 % num2).toString();
          break;
        default:
          _output = "Error";
      }
      _expression = "";
      num1 = double.parse(_output);
      operand = "";
    } else {
      if (_output == "0" || _output == "Error") {
        _output = buttonText;
        _expression = buttonText;
      } else {
        _output += buttonText;
        _expression += buttonText;
      }
    }

    setState(() {});
  }

  Widget _buildButton(String buttonText, {Color? color}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (buttonText != "=" && buttonText != "C") {
            Clipboard.setData(ClipboardData(text: buttonText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$buttonText copiado al portapapeles'),
                duration: Duration(seconds: 1),
              ),
            );
          }
          buttonPressed(buttonText);
        },
        child: ElevatedButton(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24,
              color: color ?? Colors.white,
            ),
          ),
          onPressed: () => buttonPressed(buttonText),
          style: ElevatedButton.styleFrom(
            primary: Colors.purple,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                _expression,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                _output,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Divider(),
            ),
            Column(
              children: [
                Row(
                  children: [
                    _buildButton("7"),
                    _buildButton("8"),
                    _buildButton("9"),
                    _buildButton("/"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("4"),
                    _buildButton("5"),
                    _buildButton("6"),
                    _buildButton("X"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("1"),
                    _buildButton("2"),
                    _buildButton("3"),
                    _buildButton("-"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("."),
                    _buildButton("0"),
                    _buildButton("00"),
                    _buildButton("+"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("C",
                        color: const Color.fromARGB(255, 0, 0, 0)),
                    _buildButton("="),
                  ],
                )
              ],
            )
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
