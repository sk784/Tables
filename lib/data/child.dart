class Child {
  int id;
  String firstName;
  String lastName;
  String middleName;
  int parentId;
  String birthDay;

  Child({
    this.id,
    this.firstName,
    this.lastName,
    this.middleName,
    this.parentId,
    this.birthDay
  });


  factory Child.fromJson(Map<String, dynamic> data) => Child(
      id: data["id"],
      firstName: data["first_name"],
      lastName: data["last_name"],
      middleName: data["middle_name"],
      parentId: data["parent_id"],
      birthDay: data["birthday"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "middle_name": middleName,
    "parent_id": parentId,
    "birthday": birthDay
  };
}