import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'splash.dart';
import 'home.dart';

class Trajetos extends StatefulWidget {
  const Trajetos({super.key});

  @override
  State<Trajetos> createState() => _TrajetosState();
}

class _TrajetosState extends State<Trajetos> {
  List<dynamic> pedais = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trajetos")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              trailing: Icon(Icons.chevron_left, size: 50),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.splitscreen),
              title: Text('Splash'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Splash()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.directions_bike),
              title: Text('Trajetos'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () => SystemNavigator.pop(),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Text('Registros de Pedal', style: TextStyle(fontSize: 24)),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: pedais.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: pedais[index]["imagem"] != null
                                ? Image.file(
                                    pedais[index]["imagem"],
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: 80,
                                  )
                                : Icon(Icons.image, size: 80),
                          ),
                          Text('Origem: ${pedais[index]["origem"]}'),
                          Text('Destino: ${pedais[index]["destino"]}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: novoPedal,
        child: Icon(Icons.add),
      ),
    );
  }

  void novoPedal() {
    File? imageFile;
    String latitude = "";
    String longitude = "";
    String origem = "";
    String destino = "";
    final coordenadasFuture = obterCoordenadasGPS().then((position) {
      if (position != null) {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        origem = '$latitude, $longitude';
      }
    });
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text("Novo Pedal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageFile == null
                  ? GestureDetector(
                      onTap: () async {
                        imageFile = await tirarESalvarFoto();
                        setModalState(() {
                          imageFile;
                        });
                      },
                      child: Icon(Icons.camera_alt, size: 150),
                    )
                  : Image.file(imageFile!),
              FutureBuilder<Position?>(
                future: coordenadasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return CircularProgressIndicator();
                  }
                  return TextField(
                    controller: TextEditingController(text: origem),
                    decoration: InputDecoration(hintText: "Origem"),
                    enabled: false,
                  );
                },
              ),
              TextField(
                decoration: InputDecoration(hintText: "Destino"),
                onChanged: (value) {
                  destino = value;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  pedais.add({
                    "imagem": imageFile,
                    "origem": origem,
                    "destino": destino,
                  });
                });
                Navigator.pop(context);
              },
              child: Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }

  Future<Position?> obterCoordenadasGPS() async {
    bool servicoAtivo;
    LocationPermission permissao;
    servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      return Future.error('O serviço de localização está desativado.');
    }
    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de localização negada.')),
        );
        return null;
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permissão negada permanentemente. Altere nas configurações.',
          ),
        ),
      );
      return null;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(),
    );
    return position;
  }

  Future<File?> tirarESalvarFoto() async {
    ImagePicker picker = ImagePicker();
    try {
      // 1. Abrir a câmera para tirar a foto
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (pickedImage == null) return null;
      // 2. Salvar a foto na galeria de imagens do celular
      await Gal.putImage(pickedImage.path);
      // 3. Retorna o arquivo de imagem
      return File(pickedImage.path);
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tirar ou salvar foto: $e')),
      );
    }
    return null;
  }
}
