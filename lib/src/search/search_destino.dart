import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapsapp/src/models/search_response.dart';
import 'package:mapsapp/src/models/search_result.dart';
import 'package:mapsapp/src/services/traffic_service.dart';

class SearchDestino extends SearchDelegate<SearchResult> {
  @override
  final String searchFieldLabel;
  final TrafficService _trafficService;
  final LatLng proximidad;
  final List<SearchResult> historial;

  SearchDestino(this.proximidad, this.historial)
      : this.searchFieldLabel = "Buscar...",
        this._trafficService = new TrafficService();
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => this.query = "",
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => this.close(context, SearchResult(cancelo: true)),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (this.query.length == 0) {
      return ListView(
        children: [
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Colocar el puntero en el mapa"),
            onTap: () {
              this.close(context, SearchResult(cancelo: false, manual: true));
            },
          ),
          ...this.historial.map((res) => ListTile(
                leading: Icon(Icons.history),
                title: Text(res.nombreDestino),
                subtitle: Text(res.descDestino),
                onTap: () {
                  this.close(context, res);
                },
              ))
        ],
      );
    }

    return this._construirResultadosSugerencias();
  }

  @override
  Widget buildResults(BuildContext context) {
    return this._construirResultadosSugerencias();
  }

  Widget _construirResultadosSugerencias() {
    if (this.query.length == 0) {
      return Container();
    }

    this
        ._trafficService
        .getSugerenciasPorQuery(this.query.trim(), this.proximidad);

    return StreamBuilder(
      stream: this._trafficService.sugerenciasStream,
      builder: (BuildContext context, AsyncSnapshot<SearchResponse> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final lugares = snapshot.data.features;

        if (lugares.length == 0) {
          return ListTile(
            title: Text("No hay resultados que coicidan con '$query'"),
          );
        }

        return ListView.separated(
            itemCount: lugares.length,
            separatorBuilder: (_, i) => Divider(),
            itemBuilder: (_, i) {
              final lugar = lugares[i];
              return ListTile(
                leading: Icon(Icons.place),
                title: Text(lugar.textEs),
                subtitle: Text(lugar.placeNameEs),
                onTap: () {
                  this.close(
                      context,
                      SearchResult(
                          cancelo: false,
                          manual: false,
                          coordenadasDestino:
                              LatLng(lugar.center[1], lugar.center[0]),
                          nombreDestino: lugar.textEs,
                          descDestino: lugar.placeNameEs));
                },
              );
            });
      },
    );
  }
}
