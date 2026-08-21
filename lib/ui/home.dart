import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'splash.dart';
import 'trajetos.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String latitude = "";
  String longitude = "";
  Position? p;
  File? imageFile;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              trailing: Icon(Icons.chevron_left, size: 50),
              onTap: () => Navigator.pop(context),
            ),
            DrawerHeader(child: Icon(Icons.person, size: 100)),
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.directions_bike),
              title: Text('Trajetos'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Trajetos()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () => SystemNavigator.pop(),
            ),
          ],
        ),
      ),
      body: Center(child: Text('Home')),
      floatingActionButton: FloatingActionButton(
        onPressed: novoPedal,
        child: Icon(Icons.add),
      ),
    );
  }

  void novoPedal() {
    final coordenadasFuture = obterCoordenadasGPS();
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
              FutureBuilder<void>(
                future: coordenadasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return CircularProgressIndicator();
                  }
                  return TextField(
                    controller: TextEditingController(
                      text: '$latitude, $longitude',
                    ),
                    decoration: InputDecoration(hintText: "Origem"),
                  );
                },
              ),
              TextField(decoration: InputDecoration(hintText: "Destino")),
            ],
          ),
          actions: [ElevatedButton(onPressed: () {}, child: Text("Registrar"))],
        ),
      ),
    );
  }

  Future<void> obterCoordenadasGPS() async {
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
        return Future.error('Permissão de localização negada.');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error(
        'Permissão negada permanentemente. Altere nas configurações.',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(),
    );

    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
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
