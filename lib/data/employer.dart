class Employer {
  int id;
  String firstName;
  String lastName;
  String middleName;
  String position;
  String birthDay;
  int children;

  Employer({
    this.id,
    this.firstName,
    this.lastName,
    this.middleName,
    this.position,
    this.birthDay,
    this.children
  });


  factory Employer.fromJson(Map<String, dynamic> data) => Employer(
    id: data["id"],
    firstName: data["first_name"],
    lastName: data["last_name"],
    middleName: data["middle_name"],
    position: data["position"],
    birthDay: data["birthday"],
    children: data["children"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "middle_name": middleName,
    "position": position,
    "birthday": birthDay,
    "children": children
  };
}