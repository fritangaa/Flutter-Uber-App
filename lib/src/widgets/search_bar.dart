part of "widgets.dart";

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusquedaBloc, BusquedaState>(
      builder: (context, state) {
        if (state.seleccionManual) {
          return Container();
        } else {
          return FadeInDown(
              duration: Duration(milliseconds: 500),
              child: buildSearBar(context));
        }
      },
    );
  }

  Widget buildSearBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        width: width,
        child: GestureDetector(
          onTap: () async {
            final proximidad =
                BlocProvider.of<MiUbicacionBloc>(context).state.ubicacion;
            final historial =
                BlocProvider.of<BusquedaBloc>(context).state.historial;

            final resultado = await showSearch(
                context: context,
                delegate: SearchDestino(proximidad, historial));
            this.retornoBusqueda(context, resultado);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            width: double.infinity,
            child: Text(
              "Donde quieres ir?",
              style: TextStyle(color: Colors.black87),
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 5))
                ]),
          ),
        ),
      ),
    );
  }

  Future<void> retornoBusqueda(
      BuildContext context, SearchResult result) async {
    if (result.cancelo) return;
    if (result.manual) {
      BlocProvider.of<BusquedaBloc>(context).add(OnActivarMarcadorManual());
      return;
    }

    calculandoAlerta(context);
    //calcular en base al valor del result
    final trafficService = new TrafficService();
    // ignore: close_sinks
    final mapaBloc = BlocProvider.of<MapaBloc>(context);
    final inicio = BlocProvider.of<MiUbicacionBloc>(context).state.ubicacion;
    final destino = result.coordenadasDestino;

    //obtener info del destino
    final reverseQueryResponse =
        await trafficService.getCoordenadasInfo(destino);

    final drivingResponse =
        await trafficService.getCoordsInicioFin(inicio, destino);

    final geometry = drivingResponse.routes[0].geometry;
    final duracion = drivingResponse.routes[0].duration;
    final distancia = drivingResponse.routes[0].distance;
    final nombreDestino = reverseQueryResponse.features[0].textEs;

    final points = Poly.Polyline.Decode(encodedString: geometry, precision: 6);
    final List<LatLng> rutaCoords = points.decodedCoords
        .map((point) => LatLng(point[0], point[1]))
        .toList();

    //arreglar
    mapaBloc.add(OnCrearRutaInicioDestino(
        rutaCoords, distancia, duracion, nombreDestino));

    Navigator.of(context).pop();

    //agregar historial
    // ignore: close_sinks
    final busquedaBloc = BlocProvider.of<BusquedaBloc>(context);
    busquedaBloc.add(OnAgregarHistorial(result));
  }
}
