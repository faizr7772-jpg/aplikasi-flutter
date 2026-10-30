import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katalog Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Background utama warna krem pastel yang sangat lembut
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA8E6CF), // Pastel Mint
          primary: const Color(0xFFA8E6CF),
          secondary: const Color(0xFFFFD3B6), // Pastel Peach
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF4A4A4A),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF4A4A4A)),
        ),
      ),
      home: const ProductListPage(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Mengambil SEMUA produk dari DummyJSON tanpa filter kategori
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=150'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> allProducts = data['products'];

        setState(() {
          // Menampilkan seluruh produk sesuai instruksi tugas
          products = allProducts;
          filteredProducts = allProducts;
          isLoading = false;
        });
      } else {
        print('Gagal terhubung ke API DummyJSON. Status: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error Internet/API: $e'); 
      setState(() => isLoading = false);
    }
  }

  // Fitur pencarian fungsional
  void filterSearch(String query) {
    setState(() {
      filteredProducts = query.isEmpty
          ? products
          : products.where((item) =>
              item['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
              (item['brand'] != null && item['brand'].toString().toLowerCase().contains(query.toLowerCase()))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faiz store'),
      ),
      body: Column(
        children: [
          // Search Bar Modern dengan Soft Shadow
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA8E6CF).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterSearch,
                decoration: InputDecoration(
                  hintText: 'Cari produk favoritmu...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFF8B94)), // Pastel Pink Icon
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            filterSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFA8E6CF)))
                : filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            const Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65, 
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final item = filteredProducts[index];
                          // Daftar warna pastel bergiliran untuk background card
                          final pastelColors = [
                            const Color(0xFFE0ECE4), // Soft Mint
                            const Color(0xFFFFDFD3), // Soft Peach
                            const Color(0xFFF4D6D2), // Soft Pink
                            const Color(0xFFD4E2D4), // Soft Green
                          ];
                          final cardColor = pastelColors[index % pastelColors.length];

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProductDetailPage(product: item, bgColor: cardColor)),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                      ),
                                      child: Hero(
                                        tag: 'product_img_${item['id']}',
                                        child: Image.network(
                                          item['thumbnail'],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${item['price']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFFF8B94),
                                                fontSize: 16,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                                Text(
                                                  ' ${item['rating']}',
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final dynamic product;
  final Color bgColor;

  const ProductDetailPage({super.key, required this.product, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF4A4A4A)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: bgColor,
                padding: const EdgeInsets.only(top: 60, bottom: 20),
                child: Hero(
                  tag: 'product_img_${product['id']}',
                  child: Image.network(product['thumbnail'], fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0.0, -20.0, 0.0), 
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product['title'],
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF333333),
                            height: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD3B6), // Pastel Peach
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '\$${product['price']}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product['brand'] ?? 'Produk Umum',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildInfoBadge(Icons.star_rounded, Colors.amber, '${product['rating']} Rating'),
                      const SizedBox(width: 16),
                      _buildInfoBadge(Icons.inventory_2_rounded, const Color(0xFFA8E6CF), '${product['stock']} Stok'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product['description'] ?? 'Tidak ada deskripsi tersedia.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA8E6CF), // Pastel Mint
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Beli Sekarang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF555555)),
        ),
      ],
    );
  }
}