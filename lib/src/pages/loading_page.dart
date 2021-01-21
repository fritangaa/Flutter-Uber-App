import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapsapp/src/helpers/helpers.dart';
import 'package:mapsapp/src/pages/acceso_gps_page.dart';
import 'package:mapsapp/src/pages/mapa_page.dart';
import 'package:permission_handler/permission_handler.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await Geolocator.isLocationServiceEnabled()) {
        Navigator.pushReplacement(
            context, navegarMapaFadeIn(context, MapaPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: this.checkGPSLocation(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Text(snapshot.data),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
        },
      ),
    );
  }

  Future checkGPSLocation(BuildContext context) async {
    //verificar si tengop permiso
    final permisoGPS = await Permission.location.isGranted;

    //gps activo ?
    final gspActivo = await Geolocator.isLocationServiceEnabled();

    if (permisoGPS && permisoGPS) {
      Navigator.pushReplacement(
          context, navegarMapaFadeIn(context, MapaPage()));
      return "";
    } else if (!permisoGPS) {
      Navigator.pushReplacement(
          context, navegarMapaFadeIn(context, AccesoGpsPage()));
      return "Es necesario el GPS";
    } else if (!gspActivo) {
      return "Active el GPS";
    }
  }
}
