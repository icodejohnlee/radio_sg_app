class Station {
  final int id;
  final String name;
  final String stream;
  final String genre;
  final String image;

  Station({
    required this.id,
    required this.name,
    required this.stream,
    required this.genre,
    required this.image,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      stream: json['stream'],
      genre: json['genre'],
      image: json['image'],
    );
  }
}