import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_item.dart';
import '../providers/cart.dart' show Cart;
import '../providers/order.dart' show Order;

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(), // this will make `Text` widget above take all the space
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.subtitle1.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    child: Text('ORDER NOW'),
                    textColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      Provider.of<Order>(context, listen: false).addOrder(
                        cart.items.values.toList(),
                        cart.totalAmount,
                      );

                      cart.clear();
                    },
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: ListView.builder(
                // have to use `cart.items.length` because ListView.builder will
                // then take & pass `cart.items` to itemBuilder
                // !!!!! `cart.items.length` is not just about the itemCount. Therefore,
                // cannot use `cart.itemCount` !!!!!
                itemCount: cart.items.length,
                itemBuilder: (ctx, idx) => CartItem(
                      id: cart.items.values.toList()[idx].id,
                      title: cart.items.values.toList()[idx].title,
                      quantity: cart.items.values.toList()[idx].quantity,
                      price: cart.items.values.toList()[idx].price,
                      productId: cart.items.keys.toList()[idx],
                    )),
          ),
        ],
      ),
    );
  }
}
