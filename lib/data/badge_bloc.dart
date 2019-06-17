import 'dart:async';

import 'package:samex_app/data/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:samex_app/data/samex_instance.dart';

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


  BehaviorSubject<Map<OrderType, int>> _badgeAllController = new BehaviorSubject<Map<OrderType, int>>();
  Sink<Map<OrderType, int>> get _inBadge =>_badgeAllController.sink;
  Stream<Map<OrderType, int>> get outBadges =>_badgeAllController.stream;


  ///
  /// Constructor
  ///
  BadgeBloc(){
    _badgeController.listen(_handleBadge);
  }

  void dispose(){
    _badgeController.close();
    _badgeAllController.close();
  }


  void _handleBadge(BadgeInEvent event){
    _badges[event.type] = event.badge;

    _inBadge.add(_badges);

  }

}