import 'package:fast_note/enums/sort_enums.dart';
import 'package:hive/hive.dart';
import 'settings.dart';

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    return Settings(
      displayRichLinks: reader.readBool(),
      addItemToBottom: reader.readBool(),
      themeMode: reader.readString(),
      enableSharing: reader.readBool(),
      enableFullScreen: reader.readBool(),
      defaultSortOption: SortOption.values[reader.readInt()],
      defaultGridView: reader.readBool(),
      openWithSearchBar: reader.readBool(), 
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.writeBool(obj.displayRichLinks);
    writer.writeBool(obj.addItemToBottom);
    writer.writeString(obj.themeMode);
    writer.writeBool(obj.enableSharing);
    writer.writeBool(obj.enableFullScreen);
    writer.writeInt(obj.defaultSortOption.index);
    writer.writeBool(obj.defaultGridView);
    writer.writeBool(obj.openWithSearchBar);  
  }
}