import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_app/api_client.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/models/product.dart';
import 'package:project_app/screens/product_screen.dart';
import 'package:project_app/utils.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double get width => MediaQuery.of(context).size.width;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    getProduct();
  }

  getProduct() async {
    var provider = Provider.of<ApiClient>(context, listen: false);

    if (provider.products.isEmpty) {
      setState(() {
        _isLoading = true;
      });

      await provider.fetchProduct();

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Product> products = Provider.of<ApiClient>(context).products;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : MasonryGridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              itemBuilder: (context, index) {
                final product = products[index];

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProductScreen(product: product)));
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              product.thumbnail,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: AppConstants.kAccentColor,
                                ),
                                child: Text(
                                  '${product.discountPercentage}% OFF',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.title),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8.0,
                                children: [
                                  Text(
                                    formatPrice(product.price),
                                    style: TextStyle(
                                      color: AppConstants.kPrimaryColor,
                                      fontWeight:
                                          product.discountPercentage == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      decoration:
                                          product.discountPercentage == 0
                                              ? TextDecoration.none
                                              : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  product.discountPercentage == 0
                                      ? const SizedBox()
                                      : Text(
                                          formatPrice(product.price -
                                              (product.price *
                                                      product
                                                          .discountPercentage /
                                                      100)
                                                  .round()),
                                          style: TextStyle(
                                              color: AppConstants.kPrimaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.star_rounded,
                                    color: Colors.yellow, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    product.rating.toString(),
                                    style: TextStyle(
                                        fontSize: 13.0, color: Colors.black54),
                                  ),
                                )
                              ])
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: products.length,
            ),
    );
  }
}
