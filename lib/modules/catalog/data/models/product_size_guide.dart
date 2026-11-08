class ProductSizeGuideColumn {
  final String id;
  final String label; // e.g. "محيط الصدر", "محيط الخصر", "الطول الكلي"
  final double width; // suggested min width for horizontal table display

  const ProductSizeGuideColumn({
    required this.id,
    required this.label,
    this.width = 92.0,
  });

  factory ProductSizeGuideColumn.fromMap(Map<String, dynamic> map) {
    return ProductSizeGuideColumn(
      id: (map['id'] ?? '').toString(),
      label: (map['label'] ?? '').toString(),
      width: (map['width'] as num?)?.toDouble() ?? 92.0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'width': width,
  };
}

class ProductSizeGuideRow {
  final String size; // e.g. "XS", "S", "M", "L", "XL", "XXL", "3XL"
  final Map<String, String> measurements; // columnId -> measurement value in cm

  const ProductSizeGuideRow({
    required this.size,
    required this.measurements,
  });

  String getVal(String columnId) => measurements[columnId] ?? '-';

  factory ProductSizeGuideRow.fromMap(Map<String, dynamic> map) {
    return ProductSizeGuideRow(
      size: (map['size'] ?? '').toString(),
      measurements: (map['measurements'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toMap() => {
    'size': size,
    'measurements': measurements,
  };
}

class ProductSizeGuide {
  final String title;
  final String? note;
  final List<ProductSizeGuideColumn> columns;
  final List<ProductSizeGuideRow> rows;

  const ProductSizeGuide({
    this.title = 'دليل المقاسات',
    this.note,
    required this.columns,
    required this.rows,
  });

  factory ProductSizeGuide.fromMap(Map<String, dynamic> map) {
    return ProductSizeGuide(
      title: (map['title'] ?? 'دليل المقاسات').toString(),
      note: map['note']?.toString(),
      columns: (map['columns'] as List?)
              ?.map((e) =>
                  ProductSizeGuideColumn.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      rows: (map['rows'] as List?)
              ?.map((e) =>
                  ProductSizeGuideRow.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'note': note,
    'columns': columns.map((e) => e.toMap()).toList(),
    'rows': rows.map((e) => e.toMap()).toList(),
  };

  // Standard dress and clothing guide (in cm)
  static ProductSizeGuide defaultClothingGuide() {
    return const ProductSizeGuide(
      title: 'دليل مقاسات الملابس والفساتين',
      note: 'جميع القياسات مأخوذة بالسنتيمتر (سم) للمنتج مباشرة',
      columns: [
        ProductSizeGuideColumn(id: 'chest', label: 'محيط الصدر', width: 96),
        ProductSizeGuideColumn(id: 'waist', label: 'محيط الخصر', width: 96),
        ProductSizeGuideColumn(id: 'hips', label: 'محيط الأرداف', width: 96),
        ProductSizeGuideColumn(id: 'length', label: 'الطول الكلي', width: 96),
        ProductSizeGuideColumn(id: 'shoulder', label: 'عرض الكتف', width: 92),
        ProductSizeGuideColumn(id: 'sleeve', label: 'طول الكم', width: 92),
      ],
      rows: [
        ProductSizeGuideRow(
          size: 'XS',
          measurements: {
            'chest': '82',
            'waist': '64',
            'hips': '88',
            'length': '110',
            'shoulder': '36',
            'sleeve': '58',
          },
        ),
        ProductSizeGuideRow(
          size: 'S',
          measurements: {
            'chest': '86',
            'waist': '68',
            'hips': '92',
            'length': '112',
            'shoulder': '37.5',
            'sleeve': '59',
          },
        ),
        ProductSizeGuideRow(
          size: 'M',
          measurements: {
            'chest': '90',
            'waist': '72',
            'hips': '96',
            'length': '114',
            'shoulder': '39',
            'sleeve': '60',
          },
        ),
        ProductSizeGuideRow(
          size: 'L',
          measurements: {
            'chest': '96',
            'waist': '78',
            'hips': '102',
            'length': '116',
            'shoulder': '40.5',
            'sleeve': '61',
          },
        ),
        ProductSizeGuideRow(
          size: 'XL',
          measurements: {
            'chest': '102',
            'waist': '84',
            'hips': '108',
            'length': '118',
            'shoulder': '42',
            'sleeve': '62',
          },
        ),
        ProductSizeGuideRow(
          size: 'XXL',
          measurements: {
            'chest': '108',
            'waist': '90',
            'hips': '114',
            'length': '120',
            'shoulder': '43.5',
            'sleeve': '63',
          },
        ),
        ProductSizeGuideRow(
          size: '3XL',
          measurements: {
            'chest': '114',
            'waist': '96',
            'hips': '120',
            'length': '122',
            'shoulder': '45',
            'sleeve': '64',
          },
        ),
      ],
    );
  }

  // Standard abaya guide (in cm)
  static ProductSizeGuide defaultAbayaGuide() {
    return const ProductSizeGuide(
      title: 'دليل مقاسات العبايات والجلابيات',
      note: 'مقاس العباية يعتمد أساساً على طولكِ الإجمالي بالسنتيمتر (سم)',
      columns: [
        ProductSizeGuideColumn(id: 'height_rec', label: 'طول القامة الموصى به', width: 140),
        ProductSizeGuideColumn(id: 'length', label: 'طول العباية', width: 95),
        ProductSizeGuideColumn(id: 'chest', label: 'محيط الصدر', width: 95),
        ProductSizeGuideColumn(id: 'sleeve', label: 'طول الكم', width: 90),
      ],
      rows: [
        ProductSizeGuideRow(
          size: '50',
          measurements: {
            'height_rec': '150 - 153',
            'length': '127',
            'chest': '98',
            'sleeve': '66',
          },
        ),
        ProductSizeGuideRow(
          size: '52',
          measurements: {
            'height_rec': '154 - 157',
            'length': '132',
            'chest': '102',
            'sleeve': '68',
          },
        ),
        ProductSizeGuideRow(
          size: '54',
          measurements: {
            'height_rec': '158 - 162',
            'length': '137',
            'chest': '106',
            'sleeve': '70',
          },
        ),
        ProductSizeGuideRow(
          size: '56',
          measurements: {
            'height_rec': '163 - 167',
            'length': '142',
            'chest': '110',
            'sleeve': '72',
          },
        ),
        ProductSizeGuideRow(
          size: '58',
          measurements: {
            'height_rec': '168 - 172',
            'length': '147',
            'chest': '116',
            'sleeve': '74',
          },
        ),
        ProductSizeGuideRow(
          size: '60',
          measurements: {
            'height_rec': '173 - 178',
            'length': '152',
            'chest': '122',
            'sleeve': '76',
          },
        ),
      ],
    );
  }

  // Resolver for any product
  static ProductSizeGuide forProductTitle(String title, [List<String>? availableSizes]) {
    final lower = title.toLowerCase();
    if (lower.contains('عباية') ||
        lower.contains('عبايه') ||
        lower.contains('abaya') ||
        lower.contains('جلابية') ||
        lower.contains('جلابيه')) {
      return defaultAbayaGuide();
    }
    return defaultClothingGuide();
  }
}

