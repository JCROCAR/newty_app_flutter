import 'package:educapp_demo/screens/transition/home_screen.dart'; // PANTALLA PRINCIPAL
import 'package:educapp_demo/screens/math_games/math_screen_1.dart';

import 'package:educapp_demo/screens/name_screen.dart';
//import 'package:educapp_demo/screens/principal_screen.dart'; //PANTALLA INICIO
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Paquete para animaciones Lottie
import 'package:flutter/services.dart'; // Import necesario
import 'package:http/http.dart' as http;
import 'dart:convert';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Colores',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: MathScreen1(),
      home: SplashScreen(),
      //home: HomeScreen(userName: '', gender:'M', age: '8'),
    );
  }
}





/*
class CreateProfileFlow extends StatefulWidget {
  @override
  _CreateProfileFlowState createState() => _CreateProfileFlowState();
}

class _CreateProfileFlowState extends State<CreateProfileFlow> {
  String? _name;
  int? _birthYear;
  String? _gender;

  Future<void> _submitProfile() async {
    final url = Uri.parse('http://your-django-api.com/api/profiles/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _name,
        'age': DateTime.now().year - _birthYear!,
        'gender': _gender,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile created successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create profile.')), // For debugging, you could log response.body.
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        if (_name == null)
          MaterialPage(child: NameScreen(onNext: (name) => setState(() => _name = name))),
        if (_name != null && _birthYear == null)
          MaterialPage(child: BirthYearScreen(onNext: (year) => setState(() => _birthYear = year))),
        if (_name != null && _birthYear != null && _gender == null)
          MaterialPage(child: GenderScreen(onSubmit: (gender) {
            setState(() => _gender = gender);
            _submitProfile();
          })),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}
*/

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de la pantalla
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/paisaje.jpg'), // Cambia esto por tu imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo o imagen encima del texto
                Image.asset(
                  'assets/logo.png', // Ruta de tu logo o imagen
                  height: 225, // Ajusta el tamaño del logo
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '¡Elige un juego!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FirstScreen()),
                    );
                  },
                  child: Text(
                    'Figuras',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondScreen()),
                    );
                  },
                  child: Text(
                    'Sumas',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ThirdScreen()),
                    );
                  },
                  child: Text(
                    'Selección',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen>
    with SingleTickerProviderStateMixin {
  String selectedColor = '';
  bool isCorrect = false;
  bool hasSelected = false;

  final Color highlightedColor = Colors.orangeAccent;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Método para construir los botones de color
  Widget buildColorButton(String colorName, Color color, String value) {
    bool isSelected = selectedColor == value;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(isSelected ? 0.8 : 0.4),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: color,
            width: isSelected ? 6 : 2, // Grosor del borde dinámico
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          selectedColor = value;
          isCorrect = selectedColor == 'orange';
          hasSelected = true;
        });

        if (isCorrect) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context); // Vuelve a la pantalla principal
          });
        }
      },
      child: Text(
        colorName,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de gradiente
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo_azul.jpg'), // Imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Figura(color: Colors.pink),
                    ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.2)
                          .animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeInOut,
                      )),
                      child: Figura(
                        color: highlightedColor,
                        isHighlighted: true,
                      ),
                    ),
                    Figura(color: Colors.lightBlue),
                  ],
                ),
                SizedBox(height: 40),
                Text(
                  '¿De qué color es la figura resaltada?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Botones de color
                Column(
                  children: [
                    buildColorButton('Naranja', Colors.orange, 'orange'),
                    SizedBox(height: 20),
                    buildColorButton('Rosado', Colors.pink, 'pink'),
                    SizedBox(height: 20),
                    buildColorButton('Celeste', Colors.lightBlue, 'blue'),
                  ],
                ),
                SizedBox(height: 20),
                if (hasSelected)
                  isCorrect
                      ? Lottie.asset('assets/correct.json', height: 150)
                      : Lottie.asset('assets/incorrect.json', height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final int num1 = 4; // Primer número de la suma
  final int num2 = 3; // Segundo número de la suma
  final int correctAnswer = 7; // Respuesta correcta
  String draggedValue = ''; // Valor arrastrado
  bool hasAnswered = false; // Para verificar si ya se contestó
  bool isCorrect = false; // Para verificar si la respuesta es correcta
  Color draggedColor = Colors.transparent; // Color arrastrado
  List<Map<String, dynamic>> options = [
    {'value': '6', 'color': Colors.redAccent},
    {'value': '7', 'color': Colors.greenAccent},
    {'value': '8', 'color': Colors.blueAccent}
  ]; // Lista de opciones de respuestas con colores

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de gradiente
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo_azul.jpg'), // Imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Primer número en cuadro
                    buildNumberBox(num1.toString(), Colors.purpleAccent),
                    SizedBox(width: 10),
                    Text(
                      '+',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(width: 10),
                    // Segundo número en cuadro
                    buildNumberBox(num2.toString(), Colors.purpleAccent),
                    SizedBox(width: 10),
                    Text(
                      '=',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(width: 10),
                    // Expanded para ajustar el espacio de la caja de respuesta
                    Expanded(
                      child: DragTarget<Map<String, dynamic>>(
                        onAccept: (data) {
                          setState(() {
                            draggedValue = data['value'];
                            draggedColor = data['color'];
                            hasAnswered = true;
                            isCorrect = int.parse(draggedValue) == correctAnswer;
                            if (isCorrect) {
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.pop(context); // Vuelve a la pantalla principal
                              });
                            }
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            height: 100,
                            width: 100, // Tamaño ajustado para igualar las respuestas
                            decoration: BoxDecoration(
                              color: draggedValue.isEmpty
                                  ? Colors.white
                                  : draggedColor, // El color arrastrado
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.deepPurple,
                                width: 4,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              draggedValue.isEmpty ? '?' : draggedValue,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // Botones con las posibles respuestas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: options.map((option) {
                    return buildDraggableButton(option['value'], option['color']);
                  }).toList(),
                ),
                SizedBox(height: 40),
                // Mostrar animación si ya se respondió
                if (hasAnswered)
                  isCorrect
                      ? Lottie.asset('assets/correct.json', height: 150)
                      : Lottie.asset('assets/incorrect.json', height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para los números de la suma
  Widget buildNumberBox(String number, Color color) {
    return Container(
      height: 100,
      width: 100, // Igualamos el tamaño de los cuadros de números a los de respuesta
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepPurple,
          width: 4,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Botón de opción arrastrable
  Widget buildDraggableButton(String value, Color color) {
    return Draggable<Map<String, dynamic>>(
      data: {'value': value, 'color': color},
      feedback: Material(
        color: Colors.transparent,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          ),
          onPressed: () {},
          child: Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      childWhenDragging: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
        onPressed: () {},
        child: Text(
          value,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
        onPressed: () {},
        child: Text(
          value,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  bool hasAnswered = false;
  bool isCorrectAnswer = false;
  int selectedIndex = -1; // Índice de la figura seleccionada

  void checkAnswer(bool isBicycle, int index) {
    setState(() {
      selectedIndex = index; // Actualiza la figura seleccionada
      hasAnswered = true;
      isCorrectAnswer = isBicycle;
      if (isCorrectAnswer) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context); // Vuelve a la pantalla principal
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de la pantalla
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo_azul.jpg'), // Imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Cuál de estas imágenes es una bicicleta?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Cuatro opciones de imágenes
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: EdgeInsets.all(20),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  GestureDetector(
                    onTap: () => checkAnswer(false, 0), // Marca la opción seleccionada
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedIndex == 0 ? Colors.blue[100] : Colors.white, // Cambia de color si está seleccionada
                        border: Border.all(
                          color: selectedIndex == 0 ? Colors.blue : Colors.black, // Cambia el borde si está seleccionada
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset('assets/vehiculo.png', fit: BoxFit.contain),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => checkAnswer(true, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedIndex == 1 ? Colors.blue[100] : Colors.white,
                        border: Border.all(
                          color: selectedIndex == 1 ? Colors.blue : Colors.black,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset('assets/bicicleta.png', fit: BoxFit.contain),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => checkAnswer(false, 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedIndex == 2 ? Colors.blue[100] : Colors.white,
                        border: Border.all(
                          color: selectedIndex == 2 ? Colors.blue : Colors.black,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset('assets/avion.png', fit: BoxFit.contain),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => checkAnswer(false, 3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedIndex == 3 ? Colors.blue[100] : Colors.white,
                        border: Border.all(
                          color: selectedIndex == 3 ? Colors.blue : Colors.black,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset('assets/barco.png', fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Mostrar animación según la respuesta
              if (hasAnswered)
                Center(
                  child: isCorrectAnswer
                      ? Lottie.asset('assets/correct.json', height: 150)
                      : Lottie.asset('assets/incorrect.json', height: 150),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


class Figura extends StatelessWidget {
  final Color color;
  final bool isHighlighted;

  Figura({required this.color, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: isHighlighted
            ? Border.all(color: Colors.yellowAccent, width: 8)
            : null,
        boxShadow: isHighlighted
            ? [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.6),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ]
            : [],
      ),
    );
  }
}
