import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  initState() {
    obterCoordenadasGPS();
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
      body: Center(
        child: Text(
          'Você está em \nlatitude: $latitude \nlongitude: $longitude',
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
}
