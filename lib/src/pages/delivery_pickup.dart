import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:markets/src/elements/DeliveryAddressBottomSheetWidget.dart';
import 'package:markets/src/repository/settings_repository.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/i18n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/PaymentMethodListItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/Global.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';

class DeliveryPickupWidget extends StatefulWidget {
  RouteArgument routeArgument;

  DeliveryPickupWidget({Key? key, required this.routeArgument})
      : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  late DeliveryPickupController _con;
  late PaymentMethodList list;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller as DeliveryPickupController;
  }

  @override
  void initState() {
    list = PaymentMethodList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (currentUser.value.apiToken == null) {
            //_con.requestForCurrentLocation(context);
          } else {
            // ✅ Utilisation du package google_maps_place_picker_mb
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlacePicker(
                  apiKey: setting.value.googleMapsKey!, // clé obligatoire
                  initialPosition: LatLng(
                    deliveryAddress.value?.latitude ??
                        36.8065, // position par défaut : Tunis
                    deliveryAddress.value?.longitude ?? 10.1815,
                  ),
                  useCurrentLocation: true,
                  selectInitialPosition: true,
                ),
              ),
            );

            // ✅ Vérifier le résultat du picker
            if (result != null && result is PickResult) {
              final addressText =
                  result.formattedAddress ?? result.name ?? 'Adresse inconnue';
              final lat = result.geometry?.location.lat ?? 0;
              final lng = result.geometry?.location.lng ?? 0;

              if (addressText.isNotEmpty) {
                Address address = Address.empty();
                address.address = addressText;
                address.latitude = lat;
                address.longitude = lng;

                DeliveryAddressDialog(
                  context: context,
                  address: address,
                  onChanged: (Address _address) async {
                    _con.addAddressFromDelivery(_address);
                  },
                );
              }
            }
          }
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).delivery_or_pickup,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .merge(const TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          ShoppingCartButtonWidget(
            iconColor: Theme.of(context).hintColor,
            labelColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.map,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  S.of(context).delivery_address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                subtitle: Text(
                  S.of(context).confirm_your_delivery_address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 25),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: _con.addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return DeliveryAddressesItemWidget(
                  address: _con.addresses[index],
                  onDismissed: (Address _address) {
                    _con.removeDeliveryAddress(_address);
                  },
                  onPressed: (Address _address) async {
                    print(_address.toMap());
                    deliveryAddress.value = _address;
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('select_address_id', _address.id!);
                    if (_con.addresses[index].id == null ||
                        _con.addresses[index].id == 'null') {
                      DeliveryAddressDialog(
                        context: context,
                        address: _address,
                        onChanged: (Address _address) {
                          _con.addAddress(_address);
                        },
                      );
                    } else if (['null', null]
                        .contains(_con.addresses[index].description)) {
                      DeliveryAddressDialog(
                        context: context,
                        address: _address,
                        onChanged: (Address _address) {
                          _con.updateAddress(_address);
                        },
                      );
                    } else {
                      Navigator.pop(context);
                    }
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
