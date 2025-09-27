import 'package:flutter/material.dart';
import '/../services/post_ninios_api.dart';
import '/../widgets/next_button.dart';
import '../principal_screen.dart';

class ParentsBirthdayScreen extends StatefulWidget {
  final String name;
  final String gender;
  final String age;

  ParentsBirthdayScreen({required this.name, required this.gender, required this.age});

  @override
  _ParentsBirthdayScreenState createState() => _ParentsBirthdayScreenState();
}

class _ParentsBirthdayScreenState extends State<ParentsBirthdayScreen> {
  final _controller = TextEditingController();
  bool isLoading = false;

  Future<void> _submitData() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      /*
      final success = await PostNinios.submitData(
        name: widget.name,
        gender: widget.gender,
        age: widget.age,
      );*/


      setState(() {
        isLoading = false;
      });


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos enviados correctamente')),
        );
        Navigator.pop(context); // O navega a otra pantalla

        // Navegar a HomeScreen con un nombre de usuario (puedes reemplazar 'usuario' por la variable que corresponda)
    /*Navigator.pushReplacement(
          context,

          MaterialPageRoute(
            builder: (context) => HomeScreen(userName: widget.name), // Aquí puedes pasar el nombre que necesites
          ),
        );*/

      /*
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar los datos')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa una edad')),
      );
    }*/
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/paisaje.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            '',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/paisaje.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ingresa tu año de nacimiento',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                        fontFamily: 'Comic Sans MS'
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                          fontFamily: 'Comic Sans MS'
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  isLoading
                      ? CircularProgressIndicator()
                      : CustomChildButton(
                    onPressed: _submitData,
                    text: 'Siguiente',
                  ),
                  SizedBox(height: 45)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'NEWTY',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                    fontFamily: 'Comic Sans MS'
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
