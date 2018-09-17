import 'dart:async';
import 'dart:collection';

import 'package:samex_app/data/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:samex_app/data/root_model.dart';

class BadgeInEvent {
  int badge;
  OrderType type;
  BadgeInEvent(this.badge, this.type);
}

class BadgeBloc implements BlocBase {

  ///
  /// Unique list of all favorite movies
  ///
  final Map<OrderType, int> _badges = Map();


  ///
  /// Interface that allows to remove a movie from the list of favorites
  ///
  BehaviorSubject<BadgeInEvent> _badgeController = new BehaviorSubject<BadgeInEvent>();
  Sink<BadgeInEvent> get badgeChange => _badgeController.sink;


  BehaviorSubject<Map<OrderType, int>> _favoritesController = new BehaviorSubject<Map<OrderType, int>>();
  Sink<Map<OrderType, int>> get _inFavorites =>_favoritesController.sink;
  Stream<Map<OrderType, int>> get outFavorites =>_favoritesController.stream;


  ///
  /// Constructor
  ///
  BadgeBloc(){
    _badgeController.listen(_handleBadge);
  }

  void dispose(){
    _badgeController.close();
    _favoritesController.close();
  }


  void _handleBadge(BadgeInEvent event){
    _badges[event.type] = event.badge;

    _inFavorites.add(_badges);

  }

}