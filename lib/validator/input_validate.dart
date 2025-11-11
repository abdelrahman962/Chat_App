final RegExp emailValidationRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

final RegExp passwordValidationRegex = RegExp(
  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
);

final RegExp nameValidationRegex = RegExp(
  r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$",
);
