class UserDto {
  final String id;
  final String title;
  final String firstName;
  final String lastName;
  final String picture;

  UserDto(
      {required this.id,
      required this.title,
      required this.firstName,
      required this.lastName,
      required this.picture});

  factory UserDto.fromJSON(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      title: json['title'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      picture: json['picture'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'firstName': firstName,
      'lastName': lastName,
      'picture': picture,
    };
  }
}
