
class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final int? runtime;
  final String? status;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    this.runtime,
    this.status,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'] ?? '',
      runtime: json['runtime'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'runtime': runtime,
      'status': status,
    };
  }

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
  String get backdropUrl =>
      backdropPath != null
          ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : '';
}

class TVSeries {
  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String firstAirDate;

  TVSeries({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.firstAirDate,
  });

  factory TVSeries.fromJson(Map<String, dynamic> json) {
    return TVSeries(
      id: json['id'],
      name: json['name'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
    );
  }

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
  String get backdropUrl =>
      backdropPath != null
          ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : '';
}

class Cast {
  final int id;
  final String name;
  final String? profilePath;
  final String character;

  Cast({
    required this.id,
    required this.name,
    this.profilePath,
    required this.character,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      character: json['character'] ?? '',
    );
  }

  String get profileUrl =>
      profilePath != null
          ? 'https://image.tmdb.org/t/p/w185$profilePath' : '';
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String? type;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      site: json['site'],
      type: json['type'],
    );
  }
}
