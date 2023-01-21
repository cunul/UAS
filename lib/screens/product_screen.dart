import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/database/database_queries/cart_query.dart';
import 'package:project_app/database/db_helper.dart';
import 'package:project_app/models/cart.dart';
import 'package:project_app/models/product.dart';
import 'package:project_app/preferences.dart';
import 'package:project_app/screens/checkout_screen.dart';
import 'package:project_app/utils.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  double get screenWidth => MediaQuery.of(context).size.width;

  final DbHelper _helper = DbHelper();
  // ignore: unused_field
  bool _isLoading = false;
  List<Cart> cartList = [];

  @override
  void initState() {
    super.initState();

    _getCart();
  }

  _addToCart(Cart productCart) async {
    await _helper.insert(CartQuery.TABLE_NAME, productCart.toJson());
    await _getCart();
  }

  _updateCart(Cart productCart) async {
    await _helper.update(CartQuery.TABLE_NAME, productCart.toJson());
    await _getCart();
  }

  _getCart() async {
    setState(() {
      _isLoading = true;
    });

    cartList.clear();

    await _helper.getAllData(CartQuery.TABLE_NAME).then((value) {
      for (var element in value) {
        Cart cartItem = Cart.fromJson(element);
        cartList.add(cartItem);
        print(cartItem.toJson());
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.product.title)),
      body:
          // _isLoading == true
          //     ? Center(
          //         child: CircularProgressIndicator(),
          //       )
          //     :
          SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CarouselSlider(
                  items: widget.product.images
                      .map((item) => Container(
                            color: AppConstants.kAccentColor.withOpacity(.3),
                            child: Image.network(item,
                                fit: BoxFit.contain, width: screenWidth),
                          ))
                      .toList(),
                  carouselController: _controller,
                  options: CarouselOptions(
                      viewportFraction: 1,
                      aspectRatio: 1 / 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                ),
                Positioned.fill(
                  bottom: 24,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                          widget.product.images.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppConstants.kPrimaryColor)
                                    .withOpacity(
                                        _current == entry.key ? 0.9 : 0.4)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product.title,
                          style: TextStyle(fontSize: 15),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: AppConstants.kAccentColor,
                          ),
                          child: Text(
                            '${widget.product.discountPercentage}% OFF',
                            style: TextStyle(fontSize: 13.0),
                          ),
                        ),
                      ]),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      Text(
                        formatPrice(widget.product.price),
                        style: TextStyle(
                            color: AppConstants.kPrimaryColor,
                            fontWeight: widget.product.discountPercentage == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                            decoration: widget.product.discountPercentage == 0
                                ? TextDecoration.none
                                : TextDecoration.lineThrough,
                            fontSize: 16.0),
                      ),
                      widget.product.discountPercentage == 0
                          ? const SizedBox()
                          : Text(
                              formatPrice(widget.product.price -
                                  (widget.product.price *
                                          widget.product.discountPercentage /
                                          100)
                                      .round()),
                              style: TextStyle(
                                  color: AppConstants.kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Icon(Icons.star_rounded, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.product.rating.toString(),
                        style: TextStyle(fontSize: 14.0, color: Colors.black54),
                      ),
                    )
                  ])
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 18),
              height: 8.0,
              color: AppConstants.kPrimaryLightColor.withOpacity(.3),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi',
                    style: TextStyle(color: Colors.black45),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.product.description),
                  const SizedBox(height: 8),
                  Text('Brand: ${widget.product.brand}')
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[200]!))),
        child: Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () {
                      if (Preferences().user == null) {
                        Fluttertoast.showToast(msg: 'Login terlebih dahulu!');
                      } else {
                        List<Cart> listCart = [];
                        int discountedPrice = (widget.product.price -
                                (widget.product.price *
                                    widget.product.discountPercentage /
                                    100))
                            .ceil();
                        int quantity = 1;

                        listCart.add(Cart(
                          userId: Preferences().user!.id,
                          id: widget.product.id,
                          title: widget.product.title,
                          price: widget.product.price,
                          discountPercentage: widget.product.discountPercentage,
                          discountedPrice: discountedPrice,
                          quantity: quantity,
                          total: discountedPrice * quantity,
                        ));

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CheckoutScreen(
                                    carts: listCart,
                                    subTotal: discountedPrice * 15145)));
                      }
                    },
                    child: Text('Beli Sekarang'))),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (Preferences().user == null) {
                  Fluttertoast.showToast(msg: 'Login terlebih dahulu!');
                } else {
                  int discountedPrice = (widget.product.price -
                          (widget.product.price *
                              widget.product.discountPercentage /
                              100))
                      .ceil();
                  if (cartList.isNotEmpty) {
                    for (var map in cartList) {
                      if (map.id == widget.product.id) {
                        print('update');
                        int quantity = map.quantity += 1;

                        if (map.quantity >= widget.product.stock) {
                          Fluttertoast.showToast(
                              msg: 'Produk sudah mencapai stok maksimal');
                        } else {
                          _updateCart(Cart(
                            userId: Preferences().user!.id,
                            id: widget.product.id,
                            title: widget.product.title,
                            price: widget.product.price,
                            discountPercentage:
                                widget.product.discountPercentage,
                            discountedPrice: discountedPrice,
                            quantity: quantity,
                            total: discountedPrice * quantity,
                          ));

                          Fluttertoast.showToast(
                              msg: 'Produk berhasil ditambahkan ke keranjang',
                              gravity: ToastGravity.CENTER);
                        }
                      } else {
                        print('insert');
                        int quantity = 1;

                        _addToCart(Cart(
                          userId: Preferences().user!.id,
                          id: widget.product.id,
                          title: widget.product.title,
                          price: widget.product.price,
                          discountPercentage: widget.product.discountPercentage,
                          discountedPrice: discountedPrice,
                          quantity: quantity,
                          total: discountedPrice * quantity,
                        ));

                        Fluttertoast.showToast(
                            msg: 'Produk berhasil ditambahkan ke keranjang',
                            gravity: ToastGravity.CENTER);
                      }
                    }
                  } else {
                    print('insert');
                    int quantity = 1;

                    _addToCart(Cart(
                      userId: Preferences().user!.id,
                      id: widget.product.id,
                      title: widget.product.title,
                      price: widget.product.price,
                      discountPercentage: widget.product.discountPercentage,
                      discountedPrice: discountedPrice,
                      quantity: quantity,
                      total: discountedPrice * quantity,
                    ));

                    Fluttertoast.showToast(
                        msg: 'Produk berhasil ditambahkan ke keranjang',
                        gravity: ToastGravity.CENTER);
                  }
                }
              },
              child: Text('Masukkan ke Keranjang'),
            ),
          ],
        ),
      ),
    );
  }
}
