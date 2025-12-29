import 'package:fast_note/enums/sort_enums.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Settings {
  @HiveField(0)
  bool displayRichLinks;
  
  @HiveField(1)
  bool addItemToBottom;
  
  @HiveField(2)
  String themeMode; // 'light', 'dark', or 'system'
  
  @HiveField(3)
  bool enableSharing;
  
  @HiveField(4)
  bool enableFullScreen;
  
  @HiveField(5)
  SortOption defaultSortOption;
  
  @HiveField(6)
  bool defaultGridView;

  @HiveField(7)  
  bool openWithSearchBar;  

  Settings({
    this.displayRichLinks = true,
    this.addItemToBottom = false,
    this.themeMode = 'system',
    this.enableSharing = true,
    this.enableFullScreen = true,
    this.defaultSortOption = SortOption.dateUpdated,
    this.defaultGridView = false,
    this.openWithSearchBar = false,  
  });
}