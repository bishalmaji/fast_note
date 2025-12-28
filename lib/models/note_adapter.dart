import 'package:hive/hive.dart';
import 'note.dart';

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    return Note(
      id: reader.readString(),
      title: reader.readString(),
      content: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      updatedAt: DateTime.parse(reader.readString()),
      colorHex: reader.read() as String?,
      isPinned: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.updatedAt.toIso8601String());
    writer.write(obj.colorHex);
    writer.writeBool(obj.isPinned);
  }
}