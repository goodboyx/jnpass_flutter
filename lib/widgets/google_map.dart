
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

late GoogleMapController _controller;

class GoogleMapWidget extends StatefulWidget {
  final String lat;
  final String lng;
  final bool myLocationEnabled;


  const GoogleMapWidget({
    Key? key,
    required this.lat,
    required this.lng,
    required this.myLocationEnabled,
  }) : super(key: key);

  @override
  GoogleMapWidgetState createState() => GoogleMapWidgetState();
}

class GoogleMapWidgetState extends State<GoogleMapWidget> {

  @override
  Widget build(BuildContext context) {

    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }

    debugPrint('widget.myLocationEnabled :  ${widget.myLocationEnabled}');

    List<Marker> markerList = [];
    // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

    final LatLng kMapCenter = LatLng(double.parse(widget.lat), double.parse(widget.lng));

    markerList.add(Marker(
        markerId: const MarkerId("1"),
        draggable: false,
        onTap: () => debugPrint("Marker!"),
        position: kMapCenter));


    final CameraPosition kInitialPosition = CameraPosition(
      // target: LatLng(-33.852, 151.211),
      target: kMapCenter,
      zoom: 13.0,
    );

    CameraPosition position = kInitialPosition;
    bool isMapCreated = false;
    bool isMoving = false;
    bool compassEnabled = true;
    bool mapToolbarEnabled = true;
    CameraTargetBounds cameraTargetBounds = CameraTargetBounds.unbounded;
    MinMaxZoomPreference minMaxZoomPreference = MinMaxZoomPreference.unbounded;
    MapType mapType = MapType.hybrid;
    bool rotateGesturesEnabled = true;
    bool scrollGesturesEnabled = true;
    bool tiltGesturesEnabled = false;
    bool zoomControlsEnabled = true;
    bool zoomGesturesEnabled = true;
    bool indoorViewEnabled = false;
    bool myTrafficEnabled = false;
    bool nightMode = false;


    if (defaultTargetPlatform == TargetPlatform.android) {
      // AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }

    Widget compassToggler() {
      return TextButton(
        child: Text('${compassEnabled ? 'disable' : 'enable'} compass'),
        onPressed: () {
          compassEnabled = !compassEnabled;
        },
      );
    }

    Widget mapToolbarToggler() {
      return TextButton(
        child: Text('${mapToolbarEnabled ? 'disable' : 'enable'} map toolbar'),
        onPressed: () {
          mapToolbarEnabled = !mapToolbarEnabled;
        },
      );
    }


    Widget zoomBoundsToggler() {
      return TextButton(
        child: Text(minMaxZoomPreference.minZoom == null
            ? 'bound zoom'
            : 'release zoom'),
        onPressed: () {
          minMaxZoomPreference = minMaxZoomPreference.minZoom == null
              ? const MinMaxZoomPreference(12.0, 16.0)
              : MinMaxZoomPreference.unbounded;
        },
      );
    }

    Widget mapTypeCycler() {
      final MapType nextType =
      MapType.values[(mapType.index + 1) % MapType.values.length];
      return TextButton(
        child: Text('change map type to $nextType'),
        onPressed: () {
          mapType = nextType;
        },
      );
    }

    Widget rotateToggler() {
      return TextButton(
        child: Text('${rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
        onPressed: () {
          rotateGesturesEnabled = !rotateGesturesEnabled;
        },
      );
    }

    Widget scrollToggler() {
      return TextButton(
        child: Text('${scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
        onPressed: () {
          scrollGesturesEnabled = !scrollGesturesEnabled;
        },
      );
    }

    Widget tiltToggler() {
      return TextButton(
        child: Text('${tiltGesturesEnabled ? 'disable' : 'enable'} tilt'),
        onPressed: () {
          tiltGesturesEnabled = !tiltGesturesEnabled;
        },
      );
    }

    Widget zoomToggler() {
      return TextButton(
        child: Text('${zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
        onPressed: () {
          zoomGesturesEnabled = !zoomGesturesEnabled;
        },
      );
    }

    Widget zoomControlsToggler() {
      return TextButton(
        child:
        Text('${zoomControlsEnabled ? 'disable' : 'enable'} zoom controls'),
        onPressed: () {
          zoomControlsEnabled = !zoomControlsEnabled;
        },
      );
    }

    Widget indoorViewToggler() {
      return TextButton(
        child: Text('${indoorViewEnabled ? 'disable' : 'enable'} indoor'),
        onPressed: () {
          indoorViewEnabled = !indoorViewEnabled;
        },
      );
    }

    Widget myTrafficToggler() {
      return TextButton(
        child: Text('${myTrafficEnabled ? 'disable' : 'enable'} my traffic'),
        onPressed: () {
          myTrafficEnabled = !myTrafficEnabled;
        },
      );
    }

    Future<String> getFileData(String path) async {
      return await rootBundle.loadString(path);
    }

    void setMapStyle(String mapStyle) {
      nightMode = true;
      _controller.setMapStyle(mapStyle);
    }

    // Should only be called if _isMapCreated is true.
    Widget nightModeToggler() {
      assert(isMapCreated);
      return TextButton(
        child: Text('${nightMode ? 'disable' : 'enable'} night mode'),
        onPressed: () {
          if (nightMode) {
            nightMode = false;
            _controller.setMapStyle(null);
          } else {
            getFileData('assets/night_mode.json').then(setMapStyle);
          }
        },
      );
    }


    void onMapCreated(GoogleMapController controller) {
      _controller = controller;
      isMapCreated = true;
    }

    void updateCameraPosition(CameraPosition position) {
      position = position;
    }

    final GoogleMap googleMap = GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: kInitialPosition,
        markers: Set.from(markerList),
        // liteModeEnabled: true,
        compassEnabled: compassEnabled,
        mapToolbarEnabled: mapToolbarEnabled,
        cameraTargetBounds: cameraTargetBounds,
        minMaxZoomPreference: minMaxZoomPreference,
        mapType: mapType,
        rotateGesturesEnabled: rotateGesturesEnabled,
        scrollGesturesEnabled: scrollGesturesEnabled,
        tiltGesturesEnabled: tiltGesturesEnabled,
        zoomGesturesEnabled: zoomGesturesEnabled,
        zoomControlsEnabled: zoomControlsEnabled,
        indoorViewEnabled: indoorViewEnabled,
        myLocationEnabled: widget.myLocationEnabled,
        myLocationButtonEnabled: widget.myLocationEnabled,
        trafficEnabled: myTrafficEnabled, // 교통정리
        onCameraMove: updateCameraPosition
    );

    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: <Widget> [
            Center(
              child: SizedBox(
                width: 300.0,
                height: 200.0,
                child: googleMap,
              ),
            ),
            Text('${widget.lat} / ${widget.lng}')
          ]
        )
      ),
    ];


    if (isMapCreated) {
      columnChildren.add(
        Expanded(
          child: ListView(
            children: <Widget>[
              Text('camera bearing: ${position.bearing}'),
              Text(
                  'camera target: ${position.target.latitude.toStringAsFixed(4)},'
                      '${position.target.longitude.toStringAsFixed(4)}'),
              Text('camera zoom: ${position.zoom}'),
              Text('camera tilt: ${position.tilt}'),
              // ignore: dead_code
              Text(isMoving ? '(Camera moving)' : '(Camera idle)'),
              compassToggler(),
              mapToolbarToggler(),
              mapTypeCycler(),
              zoomBoundsToggler(),
              rotateToggler(),
              scrollToggler(),
              tiltToggler(),
              zoomToggler(),
              zoomControlsToggler(),
              indoorViewToggler(),
              myTrafficToggler(),
              nightModeToggler(),
            ],
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

}
