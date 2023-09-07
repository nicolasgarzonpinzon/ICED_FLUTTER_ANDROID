import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ConsultarUsuariosApi());
}

class ConsultarUsuariosApi extends StatefulWidget {
  const ConsultarUsuariosApi({Key? key}) : super(key: key);

  @override
  State<ConsultarUsuariosApi> createState() => _ConsultarUsuariosApiState();
}

class _ConsultarUsuariosApiState extends State<ConsultarUsuariosApi> {
  List<dynamic> DatosUsuario = [];
  TextEditingController usuarioIdController = TextEditingController();

  Future<void> ConsultarDatos() async {
    final url = Uri.parse("http://10.190.82.220/ListarUsuarios");
    final Respuesta = await http.get(url);
    if (Respuesta.statusCode == 200) {
      final jsonResponse = json.decode(Respuesta.body);
      setState(() {
        DatosUsuario = List.from(jsonResponse);
      });
    } else {
      print("Error: No se consultó la Api");
    }
  }

  Future<void> BuscarUsuario(int usuarioId) async {
    final url = Uri.parse("http://10.190.82.220/BuscarUsuario/$usuarioId");
    final Respuesta = await http.get(url);
    if (Respuesta.statusCode == 200) {
      final jsonResponse = json.decode(Respuesta.body);
      setState(() {
        DatosUsuario = [jsonResponse];
      });
    } else {
      print("Error: No se encontró el Usuario");
    }
  }

  Future<void> EliminarUsuario(int usuarioId) async {
    final url = Uri.parse("http://10.190.82.220/EliminarUsuario/$usuarioId");
    final Respuesta = await http.delete(url);
    if (Respuesta.statusCode == 200) {
      final jsonResponse = json.decode(Respuesta.body);
      print(jsonResponse['Mensaje']);
      ConsultarDatos();
    } else {
      print("Error: No se pudo eliminar el Usuario");
    }
  }

  @override
  void initState() {
    super.initState();
    ConsultarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Datos Usuario"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: usuarioIdController,
                decoration: InputDecoration(
                  labelText: 'ID del Usuario',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final usuarioId = int.tryParse(usuarioIdController.text);
                  if (usuarioId != null) {
                    BuscarUsuario(usuarioId);
                  }
                },
                child: const Text('Buscar Usuario'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final usuarioId = int.tryParse(usuarioIdController.text);
                      if (usuarioId != null) {
                        // Mostrar el diálogo de confirmación
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Eliminar'),
                              content: Text('¿ESTÁS SEGURO DE ELIMINAR EL USUARIO?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Cerrar el diálogo
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Cerrar el diálogo
                                    EliminarUsuario(usuarioId);
                                  },
                                  child: Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text('Eliminar Usuario por ID'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: DatosUsuario.length,
                  itemBuilder: (context, index) {
                    final item = DatosUsuario[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                item['Usu_Documento'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(child: Text('Nombre: ${item['Usu_Nombre']}')),
                            Center(child: Text('Apellido: ${item['Usu_Apellido']}')),
                            Center(child: Text('Tipo: ${item['Usu_tipo']}')),
                            Center(child: Text('Celular: ${item['Usu_Celular']}')),
                            Center(child: Text('Correo: ${item['Usu_Correo']}')),
                            Center(child: Text('Ficha: ${item['Usu_Ficha']}')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
