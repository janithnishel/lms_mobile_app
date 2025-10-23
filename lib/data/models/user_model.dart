class User {
  final String username;

  // 💡 Token එකෙන් හෝ Backend Response එකෙන් User Object එකක් හදන factory method එකක්ද මෙහි තිබිය හැක.
  const User({required this.username});

  // optional: for debugging
  @override
  String toString() => 'User(username: $username)';
}