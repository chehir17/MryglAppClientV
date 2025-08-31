import '../models/category.dart';
import '../models/market.dart';
import '../models/media.dart';
import '../models/option.dart';
import '../models/option_group.dart';
import '../models/review.dart';

class Product {
  String id;
  String name;
  double price;
  double discountPrice;
  Media image;
  String description;
  String ingredients;
  String capacity;
  String unit;
  String packageItemsCount;
  bool featured;
  bool hide;
  bool deliverable;
  bool inStock;
  bool unique;
  Market market;
  Category category;
  List<Option> options;
  List<OptionGroup> optionGroups;
  List<Review> productReviews;

  // Constructeur principal
  Product(this.id, this.name, this.price, this.discountPrice,
      {this.description = '',
      this.capacity = '0',
      this.unit = '',
      this.packageItemsCount = '1',
      this.ingredients = '',
      this.featured = false,
      this.hide = false,
      this.deliverable = false,
      this.inStock = false,
      this.unique = false,
      Market? market,
      Category? category,
      Media? image,
      List<Option>? options,
      List<OptionGroup>? optionGroups,
      List<Review>? productReviews})
      : this.market = market ?? Market.empty(),
        this.category = category ?? Category(),
        this.image = image ?? Media(),
        this.options = options ?? [],
        this.optionGroups = optionGroups ?? [],
        this.productReviews = productReviews ?? [];

  // Constructeur pour créer un produit vide
  Product.empty()
      : id = '',
        name = '',
        price = 0.0,
        discountPrice = 0.0,
        description = '',
        ingredients = '',
        capacity = '0',
        unit = '',
        packageItemsCount = '1',
        featured = false,
        hide = false,
        deliverable = false,
        inStock = false,
        unique = false,
        market = Market.empty(),
        category = Category(),
        image = Media(),
        options = [],
        optionGroups = [],
        productReviews = [];

  // Constructeur depuis JSON
  Product.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name'] ?? '',
        price = (jsonMap['price'] != null) ? jsonMap['price'].toDouble() : 0.0,
        discountPrice = (jsonMap['discount_price'] != null)
            ? jsonMap['discount_price'].toDouble()
            : 0.0,
        description = jsonMap['description'] ?? '',
        ingredients = jsonMap['ingredients'] ?? '',
        capacity = jsonMap['capacity']?.toString() ?? '0',
        unit = jsonMap['unit']?.toString() ?? '',
        packageItemsCount = jsonMap['package_items_count']?.toString() ?? '1',
        featured = jsonMap['featured'] ?? false,
        hide = jsonMap['hide'] ?? false,
        deliverable = jsonMap['deliverable'] ?? false,
        inStock = jsonMap['in_stock'] ?? false,
        unique = jsonMap['unique_product'] ?? false,
        market = (jsonMap['market'] != null)
            ? Market.fromJSON(jsonMap['market'])
            : Market.empty(),
        category = (jsonMap['category'] != null)
            ? Category.fromJSON(jsonMap['category'])
            : Category(),
        image =
            (jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty)
                ? Media.fromJSON(jsonMap['media'][0])
                : Media(),
        options = (jsonMap['options'] != null &&
                (jsonMap['options'] as List).isNotEmpty)
            ? List<Option>.from(
                (jsonMap['options'] as List).map((e) => Option.fromJSON(e)))
            : [],
        optionGroups = (jsonMap['option_groups'] != null &&
                (jsonMap['option_groups'] as List).isNotEmpty)
            ? List<OptionGroup>.from((jsonMap['option_groups'] as List)
                .map((e) => OptionGroup.fromJSON(e)))
            : [],
        productReviews = (jsonMap['product_reviews'] != null &&
                (jsonMap['product_reviews'] as List).isNotEmpty)
            ? List<Review>.from((jsonMap['product_reviews'] as List)
                .map((e) => Review.fromJSON(e)))
            : [] {
    // Ajuster price si discountPrice existe
    if (discountPrice != 0.0) {
      price = discountPrice;
    } else if (jsonMap['price'] != null) {
      discountPrice = jsonMap['price'].toDouble();
    }
  }

  // Convertir en Map
  Map toMap() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "discountPrice": discountPrice,
      "description": description,
      "capacity": capacity,
      "package_items_count": packageItemsCount,
    };
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }
}
