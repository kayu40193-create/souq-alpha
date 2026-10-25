
import 'package:flutter/material.dart';

void main() {
  runApp(const SouqAlphaApp());
}

const Color brand = Color(0xFF087F5B);
const Color pageBg = Color(0xFFF5F7F6);

class Product {
  final String name;
  final String category;
  final String emoji;
  final double price;
  final Color color;
  int quantity;

  Product({
    required this.name,
    required this.category,
    required this.emoji,
    required this.price,
    required this.color,
    this.quantity = 1,
  });
}

class SouqAlphaApp extends StatelessWidget {
  const SouqAlphaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'سوق ألفا',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBg,
        colorScheme: ColorScheme.fromSeed(seedColor: brand),
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),
      home: const StoreHome(),
    );
  }
}

class StoreHome extends StatefulWidget {
  const StoreHome({super.key});

  @override
  State<StoreHome> createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  int tab = 0;
  String selectedCategory = 'الكل';
  String search = '';

  final TextEditingController searchController = TextEditingController();

  final List<Product> products = [
    Product(
      name: 'سماعات لاسلكية',
      category: 'إلكترونيات',
      emoji: '🎧',
      price: 12.50,
      color: const Color(0xFFE2EAFE),
    ),
    Product(
      name: 'ساعة ذكية',
      category: 'إلكترونيات',
      emoji: '⌚',
      price: 25.00,
      color: const Color(0xFFE5E0F8),
    ),
    Product(
      name: 'حقيبة يومية',
      category: 'أزياء',
      emoji: '👜',
      price: 18.75,
      color: const Color(0xFFFBE5D7),
    ),
    Product(
      name: 'حذاء رياضي',
      category: 'أزياء',
      emoji: '👟',
      price: 32.00,
      color: const Color(0xFFE0F1E8),
    ),
    Product(
      name: 'مصباح مكتبي',
      category: 'المنزل',
      emoji: '💡',
      price: 9.99,
      color: const Color(0xFFFFF0C9),
    ),
    Product(
      name: 'نبتة للزينة',
      category: 'المنزل',
      emoji: '🪴',
      price: 6.50,
      color: const Color(0xFFDDF1DC),
    ),
  ];

  final Set<String> favorites = {};
  final List<Product> cart = [];

  final List<String> categories = [
    'الكل',
    'إلكترونيات',
    'أزياء',
    'المنزل',
  ];

  List<Product> get visibleProducts {
    return products.where((p) {
      final matchesCategory =
          selectedCategory == 'الكل' ||
          p.category == selectedCategory;
      final matchesSearch =
          p.name.contains(search) ||
          p.category.contains(search);
      final matchesTab = tab != 1 || favorites.contains(p.name);
      return matchesCategory && matchesSearch && matchesTab;
    }).toList();
  }

  int get cartCount =>
      cart.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal =>
      cart.fold(0, (sum, item) => sum + item.price * item.quantity);

  void addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere((p) => p.name == product.name);
      if (index >= 0) {
        cart[index].quantity++;
      } else {
        cart.add(Product(
          name: product.name,
          category: product.category,
          emoji: product.emoji,
          price: product.price,
          color: product.color,
        ));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${product.name} إلى السلة'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void addProduct() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String category = 'إلكترونيات';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة منتج'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'السعر بالدينار الأردني',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'القسم',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .where((c) => c != 'الكل')
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => category = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(
                  priceController.text.trim().replaceAll(',', '.'),
                );

                if (name.isEmpty || price == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('أدخل اسمًا وسعرًا صحيحين'),
                    ),
                  );
                  return;
                }

                setState(() {
                  products.insert(
                    0,
                    Product(
                      name: name,
                      category: category,
                      emoji: '🛍️',
                      price: price,
                      color: const Color(0xFFE0F1E8),
                    ),
                  );
                  selectedCategory = 'الكل';
                  tab = 0;
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: brand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سوق ألفا',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'تسوّق كل ما تحتاجه',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'إضافة منتج',
              onPressed: addProduct,
              icon: const Icon(Icons.add_business_outlined),
            ),
            IconButton(
              tooltip: 'السلة',
              onPressed: () => setState(() => tab = 2),
              icon: Badge(
                label: Text('$cartCount'),
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ],
        ),
        body: tab == 2 ? buildCart() : buildStore(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (index) {
            setState(() => tab = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'المتجر',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'السلة',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStore() {
    final items = visibleProducts;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF075B46), Color(0xFF11A477)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً بك في سوق ألفا 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'اكتشف منتجات مميزة بأسعار مناسبة',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'تسوّق بسهولة من مكان واحد',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: searchController,
          onChanged: (value) => setState(() => search = value.trim()),
          decoration: InputDecoration(
            hintText: 'ابحث عن منتج...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: search.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() => search = '');
                    },
                    icon: const Icon(Icons.close),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'الأقسام',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = selectedCategory == category;

              return ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) {
                  setState(() => selectedCategory = category);
                },
                selectedColor: brand.withAlpha(35),
                side: BorderSide(
                  color: selected ? brand : Colors.grey.shade300,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tab == 1 ? 'منتجاتك المفضلة' : 'منتجات مميزة',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${items.length} منتجات',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: Text('لا توجد منتجات هنا حاليًا'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final product = items[index];
              final favorite = favorites.contains(product.name);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: product.color,
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                product.emoji,
                                style: const TextStyle(fontSize: 66),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              left: 6,
                              child: IconButton.filledTonal(
                                onPressed: () {
                                  setState(() {
                                    if (favorite) {
                                      favorites.remove(product.name);
                                    } else {
                                      favorites.add(product.name);
                                    }
                                  });
                                },
                                icon: Icon(
                                  favorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: favorite ? Colors.red : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${product.price.toStringAsFixed(2)} د.أ',
                        style: const TextStyle(
                          color: brand,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: FilledButton.icon(
                        onPressed: () => addToCart(product),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('أضف للسلة'),
                        style: FilledButton.styleFrom(
                          backgroundColor: brand,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget buildCart() {
    return Column(
      children: [
        Expanded(
          child: cart.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'سلتك فارغة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text('أضف منتجات من المتجر لتظهر هنا'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final product = cart[index];

                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: product.color,
                          child: Text(product.emoji),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          '${product.price.toStringAsFixed(2)} د.أ × ${product.quantity}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() => cart.removeAt(index));
                          },
                        ),
                        onTap: () {
                          setState(() => product.quantity++);
                        },
                      ),
                    );
                  },
                ),
        ),
        if (cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المجموع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${cartTotal.toStringAsFixed(2)} د.أ',
                        style: const TextStyle(
                          color: brand,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تأكيد الطلب'),
                            content: const Text(
                              'هذه نسخة تجريبية. لا يتم إرسال الطلب أو الدفع عبر الإنترنت بعد.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('حسنًا'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: brand,
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text('متابعة الطلب'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
