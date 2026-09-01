import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'splash.dart';
import 'trajetos.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //_latitude e _longitude de São Paulo, Brasil, como valores padrão caso a localização não seja obtida.
  LatLng _origem = LatLng(-23.550520, -46.633308);
  LatLng? _destino;

  late final coordenadasFuture = obterCoordenadasGPS().then((position) {
    if (position != null) {
      _origem = LatLng(position.latitude, position.longitude);
    }
  });

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bem vindo ao Pedal!"),
            Text("Clique no mapa para selecionar o destino:"),
            FutureBuilder<Position?>(
              future: coordenadasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return CircularProgressIndicator();
                }
                return Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _origem,
                      zoom: 14.0,
                    ),
                    onTap: (LatLng latLng) {
                      // Callback acionado ao clicar em qualquer lugar do mapa
                      setState(() {
                        _destino = latLng;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '_latitude: ${latLng.latitude}, _longitude: ${latLng.longitude}',
                          ),
                        ),
                      );
                    },
                    markers: {
                      Marker(markerId: MarkerId('origem'), position: _origem),
                      if (_destino != null)
                        Marker(
                          markerId: MarkerId('clicado'),
                          position: _destino!,
                        ),
                    },
                  ),
                );
              },
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
}
