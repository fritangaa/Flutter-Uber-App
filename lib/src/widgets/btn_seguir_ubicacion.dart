part of "widgets.dart";

class BtnSeguirUbicacion extends StatelessWidget {
  const BtnSeguirUbicacion({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final mapaBloc = BlocProvider.of<MapaBloc>(context);

    return BlocBuilder<MapaBloc, MapaState>(builder: (context, state) {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          maxRadius: 25,
          child: IconButton(
            icon: Icon(
              mapaBloc.state.seguirUbicacion
                  ? Icons.accessibility_new
                  : Icons.directions_run,
              color: Colors.black87,
            ),
            onPressed: () {
              mapaBloc.add(OnSeguirUbicacion());
            },
          ),
        ),
      );
    });
  }
}
