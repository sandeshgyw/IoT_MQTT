import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt/widgets/button_widget.dart';
import 'package:mqtt/widgets/constants.dart';

import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter + IoT + NodeMCU'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String broker = 'broker.hivemq.com';
  int port = 1883;
  String username = 'admin';
  String passwd = 'hivemq';
  String clientIdentifier = 'Esp8266Client';
  bool value = false;
  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState;

  String _temp = "20";
  String _hum = "20";
  Color glowcolor = Colors.lightBlueAccent;

  StreamSubscription subscription;

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  void publishMessage(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('MQTTClientWrapper::Publishing message $message to topic ');
    client.publishMessage(
        "sandesh/8761/switchstate", MqttQos.exactlyOnce, builder.payload);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      // title: 'Welcome to Flutter',
      home: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
              label: Text("Connect"),
              icon: Icon(Icons.replay),
              onPressed: () {
                _connect();
              }),
          // key: _scaffoldKey,
          drawer: Drawer(
              child: new ListView(
            children: <Widget>[
              new DrawerHeader(
                child: new Text("DRAWER HEADER.."),
                decoration: new BoxDecoration(color: Colors.orange),
              ),
              new ListTile(
                title: new Text("Item => 1"),
                onTap: () {},
              ),
              new ListTile(
                title: new Text("Item => 2"),
                onTap: () {},
              ),
            ],
          )),
          body: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        // _scaffoldKey.currentState.openDrawer();
                      },
                      child: CircularSoftButton(
                        icon: Icon(Icons.clear_all),
                      ),
                    ),
                    Text("MY ROOM",
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    CircularSoftButton(
                      icon: Icon(Icons.settings),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Temperature",
                                style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            margin: EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(_temp.toString() + "°C",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 40)),
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              // border: Border.all(
                              //     color: Colors.lightBlueAccent,
                              //     width: 2),
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                colors: [shadowColor, lightShadowColor],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: glowcolor,
                                  // offset: Offset(8, 6),
                                  // spreadRadius: _animation.value,
                                  // blurRadius: _animation.value
                                ),
                                BoxShadow(
                                  // spreadRadius: _animation.value,
                                  // blurRadius: _animation.value,
                                  color: glowcolor,
                                  // offset: Offset(-8, -6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Humidity",
                                style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            margin: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text(_hum.toString() + "%",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 40)),
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              // border: Border.all(
                              //     color: Colors.lightBlueAccent,
                              //     width: 2),
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                colors: [shadowColor, lightShadowColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  // spreadRadius: _animation.value,
                                  // blurRadius: _animation.value,
                                  color: glowcolor,
                                  // offset: Offset(8, 6),
                                ),
                                BoxShadow(
                                  // spreadRadius: _animation.value,
                                  // blurRadius: _animation.value,
                                  color: glowcolor,
                                  // offset: Offset(-8, -6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FloatingActionButton.extended(
                    label: value ? Text("ON") : Text("OFF"),
                    icon: value
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        value = !value;
                      });
                      if (client.connectionStatus.state ==
                          mqtt.MqttConnectionState.connected) {
                        value ? publishMessage("OFF") : publishMessage("ON");
                      } else {}
                    }),
              ],
            ),
          )),
    );
  }

  void _connect() async {
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
    /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
    /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
    /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
    /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
    /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
    /// of 1883 is used.
    /// If you want to use websockets rather than TCP see below.
    ///
    client = mqtt.MqttClient(broker, '');
    client.port = port;

    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    /// client.useWebSocket = true;
    /// client.port = 80;  ( or whatever your WS port is)
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.
    /// Set logging on if needed, defaults to off
    client.logging(on: true);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 30;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect(username, passwd);
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionStatus.state == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] connected');
      setState(() {
        connectionState = client.connectionStatus.state;
      });
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus.state}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);

    _subscribeToTopic("sandesh/8761");
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    setState(() {
      //topics.clear();
      connectionState = client.connectionStatus.state;
      client = null;
      subscription.cancel();
      subscription = null;
    });
    print('[MQTT client] MQTT client disconnected');
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
        event[0].payload as mqtt.MqttPublishMessage;
    final String message =
        mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- $message -->');
    print(client.connectionStatus.state);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: $message");
    setState(() {
      var parsedJson = json.decode(message);
      _temp = parsedJson['Temperature:'];
      _hum = parsedJson['Humidity:'];
    });
  }
}
