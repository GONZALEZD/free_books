enum BookmarkType {
  automatic,
  user,
}

extension BookmarkTypeString on BookmarkType {
  String get string {
    switch(this) {
      case BookmarkType.automatic: return "automatic";
      case BookmarkType.user: return "user";
    }
    throw "Unknown String representation for value $this";
  }

  static BookmarkType parse(String source) {
    switch(source) {
      case "automatic": return BookmarkType.automatic;
      case "user": return BookmarkType.user;
      default:
        return BookmarkType.automatic;
    }
  }
}

class Bookmark {
  final int id;
  final DateTime lastReading;
  final BookmarkType type;
  final String cfi;

  Bookmark({this.lastReading, this.type, this.cfi,this.id});

  Bookmark merge({Bookmark other}) {
    return Bookmark(
      lastReading: other.lastReading ?? this.lastReading,
      cfi: other.cfi ?? this.cfi,
      type: other.type ?? this.type,
      id: other.id ?? this.id,
    );
  }

  factory Bookmark.automatic({String cfi}) {
    return Bookmark(
      type: BookmarkType.automatic,
      lastReading: DateTime.now(),
      cfi: cfi,
    );
  }

  factory Bookmark.user({String cfi}) {
    return Bookmark(
      type: BookmarkType.user,
      lastReading: DateTime.now(),
      cfi: cfi,
    );
  }
}