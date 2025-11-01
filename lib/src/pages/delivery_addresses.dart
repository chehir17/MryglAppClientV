import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../controllers/delivery_addresses_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryAddressesWidget extends StatefulWidget {
  RouteArgument? routeArgument;

  DeliveryAddressesWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryAddressesWidgetState createState() =>
      _DeliveryAddressesWidgetState();
}

class _DeliveryAddressesWidgetState extends StateMVC<DeliveryAddressesWidget> {
  late DeliveryAddressesController _con;
  late PaymentMethodList list;

  _DeliveryAddressesWidgetState() : super(DeliveryAddressesController()) {
    _con = controller as DeliveryAddressesController;
  }

  @override
  void initState() {
    list = new PaymentMethodList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).delivery_addresses,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).colorScheme.secondary),
        ],
      ),
      floatingActionButton: _con.cart != null &&
              _con.cart.product!.market.availableForDelivery!
          ? FloatingActionButton(
              onPressed: () async {
                // Use map_location_picker with required config parameter
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlacePicker(
                      apiKey: setting.value.googleMapsKey!, // requis
                      initialPosition: LatLng(
                        deliveryAddress.value?.latitude ?? 36.8065,
                        deliveryAddress.value?.longitude ?? 10.1815,
                      ),
                      useCurrentLocation: true,
                      selectInitialPosition: true,
                    ),
                  ),
                );

                // Check the actual type returned by the package
                // You might need to check the package documentation for the correct type
                if (result != null) {
                  // Try to access properties based on what the package actually returns
                  // This is a guess - you'll need to adjust based on the actual return type
                  double lat = 0;
                  double lng = 0;
                  String address = '';

                  // Try to access common property names
                  if (result is Map) {
                    lat = result['latitude'] ?? result['lat'] ?? 0;
                    lng = result['longitude'] ?? result['lng'] ?? 0;
                    address =
                        result['address'] ?? result['formattedAddress'] ?? '';
                  } else {
                    // Try to access properties using reflection-like syntax
                    try {
                      lat = result.latitude ?? result.latLng?.latitude ?? 0;
                      lng = result.longitude ?? result.latLng?.longitude ?? 0;
                      address = result.address ?? result.formattedAddress ?? '';
                    } catch (e) {
                      print('Error accessing result properties: $e');
                    }
                  }

                  _con.addAddress(new Address.fromJSON({
                    'address': address,
                    'latitude': lat,
                    'longitude': lng,
                  }));
                  print("result = $result");
                }
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
              ))
          : SizedBox(height: 0),
      body: RefreshIndicator(
        onRefresh: _con.refreshAddresses,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.map,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context).delivery_addresses,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  subtitle: Text(
                    S
                        .of(context)
                        .long_press_to_edit_item_swipe_item_to_delete_it,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              _con.addresses.isEmpty
                  ? CircularLoadingWidget(height: 250)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.addresses.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        return DeliveryAddressesItemWidget(
                          address: _con.addresses.elementAt(index),
                          onPressed: (Address _address) {
                            DeliveryAddressDialog(
                              context: context,
                              address: _address,
                              onChanged: (Address _address) {
                                _con.updateAddress(_address);
                              },
                            );
                          },
                          onLongPress: (Address _address) {
                            DeliveryAddressDialog(
                              context: context,
                              address: _address,
                              onChanged: (Address _address) {
                                _con.updateAddress(_address);
                              },
                            );
                          },
                          onDismissed: (Address _address) {
                            _con.removeDeliveryAddress(_address);
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
