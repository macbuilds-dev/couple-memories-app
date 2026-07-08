import 'package:flutter_test/flutter_test.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';

void main() {
  group('Memory model', () {
    test('serializes and deserializes with media files', () {
      final memory = Memory(
        id: 1,
        date: DateTime(2024, 2, 14),
        title: 'Valentine\'s Day',
        description: 'A special evening',
        location: 'Home',
        isFavorite: true,
        mediaFiles: [
          MediaFile(path: '/tmp/photo.jpg', type: MediaType.image),
        ],
      );

      final json = memory.toJson();
      final restored = Memory.fromJson(json);

      expect(restored.id, memory.id);
      expect(restored.title, memory.title);
      expect(restored.isFavorite, true);
      expect(restored.mediaFiles.length, 1);
      expect(restored.mediaFiles.first.isImage, true);
    });

    test('copyWith updates selected fields', () {
      final memory = Memory(
        id: 1,
        date: DateTime(2024, 1, 1),
        title: 'Original',
        description: 'Desc',
        location: 'Place',
        isFavorite: false,
      );

      final updated = memory.copyWith(title: 'Updated', isFavorite: true);

      expect(updated.title, 'Updated');
      expect(updated.isFavorite, true);
      expect(updated.id, memory.id);
    });
  });
}
