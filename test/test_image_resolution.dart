import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(
      envString: 'ENABLE_MOCK_DATA=false\nAPP_ENV=development\nAPI_BASE_URL=http://10.0.2.2:8000',
    );
  });

  test('Test image resolution for product with gallery map list and string list', () {
    final json = {
      'id': 1,
      'title': 'Test Product',
      'feature_image': 'http://127.0.0.1:8000/storage/media/1/feat.webp',
      'images': [
        'http://127.0.0.1:8000/storage/media/1/feat.webp',
        'http://127.0.0.1:8000/storage/media/2/gal1.webp',
      ],
      'gallery': [
        'http://127.0.0.1:8000/storage/media/2/gal1.webp',
        'http://127.0.0.1:8000/storage/media/3/gal2.webp',
      ],
      'gallery_media': [
        {
          'id': 4,
          'url': 'http://127.0.0.1:8000/storage/media/4/gal3.webp',
          'thumb': 'http://127.0.0.1:8000/storage/media/4/conversions/thumb.webp',
        },
      ],
    };

    final item = HomeProductItem.fromJson(json);
    expect(item.images.length, 4);
    expect(item.images[0], 'http://10.0.2.2:8000/storage/media/1/feat.webp');
    expect(item.images[1], 'http://10.0.2.2:8000/storage/media/2/gal1.webp');
    expect(item.images[2], 'http://10.0.2.2:8000/storage/media/3/gal2.webp');
    expect(item.images[3], 'http://10.0.2.2:8000/storage/media/4/gal3.webp');

    for (final img in item.images) {
      expect(img.startsWith('http://10.0.2.2:8000'), isTrue);
      expect(img.contains('{'), isFalse);
    }
  });
}
