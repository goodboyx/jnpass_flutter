class AreaLoc {
  final int locId;
  final String locName;

  AreaLoc({required this.locId, required this.locName});

  factory AreaLoc.fromJson(Map<String, dynamic> parsedJson){
    return AreaLoc(
        locId:parsedJson['id'],
        locName:parsedJson['val']
    );
  }
}