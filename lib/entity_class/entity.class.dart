part of '../main.dart';

class Entity {
  static const STATE_ICONS_COLORS = {
    "on": Colors.amber,
    "off": Color.fromRGBO(68, 115, 158, 1.0),
    "default": Color.fromRGBO(68, 115, 158, 1.0),
    "unavailable": Colors.black12,
    "unknown": Colors.black12,
    "playing": Colors.amber
  };
  static const badgeColors = {
    "default": Color.fromRGBO(223, 76, 30, 1.0),
    "binary_sensor": Color.fromRGBO(3, 155, 229, 1.0)
  };
  static List badgeDomains = [
    "alarm_control_panel",
    "binary_sensor",
    "device_tracker",
    "updater",
    "sun",
    "timer",
    "sensor"
  ];

  static const rightWidgetPadding = 14.0;
  static const leftWidgetPadding = 8.0;
  static const extendedWidgetHeight = 50.0;
  static const iconSize = 28.0;
  static const stateFontSize = 16.0;
  static const nameFontSize = 16.0;
  static const smallFontSize = 14.0;
  static const largeFontSize = 24.0;
  static const inputWidth = 160.0;
  static const rowPadding = 10.0;

  double widgetHeight = 34.0;

  Map attributes;
  String domain;
  String entityId;
  String state;
  String assumedState;
  DateTime _lastUpdated;

  List<Entity> childEntities = [];

  List<String> attributesToShow = ["all"];

  String get displayName =>
      attributes["friendly_name"] ?? (attributes["name"] ?? "_");

  String get deviceClass => attributes["device_class"] ?? null;
  bool get isView =>
      (domain == "group") &&
      (attributes != null ? attributes["view"] ?? false : false);
  bool get isGroup => domain == "group";
  bool get isBadge => Entity.badgeDomains.contains(domain);
  String get icon => attributes["icon"] ?? "";
  bool get isOn => state == "on";
  String get entityPicture => attributes["entity_picture"];
  String get unitOfMeasurement => attributes["unit_of_measurement"] ?? "";
  List get childEntityIds => attributes["entity_id"] ?? [];
  String get lastUpdated => _getLastUpdatedFormatted();
  bool get isHidden => attributes["hidden"] ?? false;

  Entity(Map rawData) {
    update(rawData);
  }

  void update(Map rawData) {
    attributes = rawData["attributes"] ?? {};
    domain = rawData["entity_id"].split(".")[0];
    entityId = rawData["entity_id"];
    state = rawData["state"];
    assumedState = state;
    _lastUpdated = DateTime.tryParse(rawData["last_updated"]);
  }

  double _getDoubleAttributeValue(String attributeName) {
    var temp1 = attributes["$attributeName"];
    if (temp1 is int) {
      return temp1.toDouble();
    } else if (temp1 is double) {
      return temp1;
    } else {
      return double.tryParse("$temp1");
    }
  }

  int _getIntAttributeValue(String attributeName) {
    var temp1 = attributes["$attributeName"];
    if (temp1 is int) {
      return temp1;
    } else if (temp1 is double) {
      return temp1.round();
    } else {
      return int.tryParse("$temp1");
    }
  }

  Widget buildDefaultWidget(BuildContext context) {
    return EntityModel(
      entity: this,
      child: DefaultEntityContainer(
          state: _buildStatePart(context),
          height: widgetHeight,
      ),
      handleTap: true,
    );
  }

  Widget _buildStatePart(BuildContext context) {
    return SimpleEntityState();
  }

  Widget _buildStatePartForPage(BuildContext context) {
    return _buildStatePart(context);
  }

  Widget _buildAdditionalControlsForPage(BuildContext context) {
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  Widget buildEntityPageWidget(BuildContext context) {
    return EntityModel(
      entity: this,
      child: EntityPageContainer(children: <Widget>[
        DefaultEntityContainer(state: _buildStatePartForPage(context), height: widgetHeight),
        LastUpdatedWidget(),
        Divider(),
        buildHistoryWidget(),
        _buildAdditionalControlsForPage(context),
        EntityAttributesList()
      ]),
      handleTap: false,
    );
  }

  Widget buildHistoryWidget() {
    return EntityHistoryWidget(
      type: EntityHistoryWidgetType.simplest,
    );
  }

  Widget buildBadgeWidget(BuildContext context) {
    return EntityModel(
      entity: this,
      child: BadgeWidget(),
      handleTap: true,
    );
  }

  String getAttribute(String attributeName) {
    if (attributes != null) {
      return attributes["$attributeName"];
    }
    return null;
  }

  String _getLastUpdatedFormatted() {
    if (_lastUpdated == null) {
      return "-";
    } else {
      DateTime now = DateTime.now();
      Duration d = now.difference(_lastUpdated);
      String text;
      int v;
      if (d.inDays == 0) {
        if (d.inHours == 0) {
          if (d.inMinutes == 0) {
            text = "seconds ago";
            v = d.inSeconds;
          } else {
            text = "minutes ago";
            v = d.inMinutes;
          }
        } else {
          text = "hours ago";
          v = d.inHours;
        }
      } else {
        text = "days ago";
        v = d.inDays;
      }
      return "$v $text";
    }
  }
}
