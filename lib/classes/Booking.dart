class BookingState {
  static final BookingState _instance = BookingState._internal();
  bool _isBooked = false;

  factory BookingState() {
    return _instance;
  }

  BookingState._internal();

  bool get isBooked => _isBooked;

  void setBooked(bool value) {
    _isBooked = value;
  }
}