import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
enum UniLinksType { string, uri }
class _HomePageState extends State<HomePage> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "");
  final subjectText = TextEditingController(text: "My Plugin Test Meeting");
  final nameText = TextEditingController(text: "");
  final emailText = TextEditingController(text: "");
  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;
  var enableJoinMeeting = false;

  String _latestLink = 'Unknown';
  Uri _latestUri;
  UniLinksType _type = UniLinksType.string;

  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
    if (_sub != null) _sub.cancel();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    if (_type == UniLinksType.string) {
      await initPlatformStateForStringUniLinks();
    } else {
      await initPlatformStateForUriUniLinks();
    }
  }

  initPlatformStateForUriUniLinks() async{
    print("initPlatformStateForUriUniLinks");
  }

  /// An implementation using a [String] link
  initPlatformStateForStringUniLinks() async {
    print("initPlatformStateForStringUniLinks");
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      setState(() {
        _latestLink = link ?? 'Unknown';
        _latestUri = null;
        try {
          if (link != null) _latestUri = Uri.parse(link);
        } on FormatException {}
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestLink = 'Failed to get latest link: $err.';
        _latestUri = null;
      });
    });

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      print('got link: $link');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest link
    String initialLink;
    Uri initialUri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
      if (initialLink != null) initialUri = Uri.parse(initialLink);
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
      initialUri = null;
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
      initialUri = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = initialLink;
      _latestUri = initialUri;
      print("Path: ${_latestUri?.path}");
      if(initialLink != null && "${_latestUri?.path}" != null && "${_latestUri?.path}".trim() != "") {
        roomText.text = "${_latestUri?.path}".replaceFirst("/", "");
        enableJoinMeeting = true;
      }
      else
        roomText.text = "";
    });
    //print("Path: ${_latestUri?.path}");

  }

  String validateRoomName(String value){
    if (value != null && !(value.trim().length >= 10) && value.trim().isNotEmpty) {
      setState(() {
        enableJoinMeeting = false;
      });
      return "Room Name should be minimum 10 characters";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    //roomText.text = "Hello Kiran1";
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        //leading: BackButton(),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32)
              ),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 24.0,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextField(
                        controller: roomText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Room Name *",
                          hintText: "Enter Room Name",
                          errorText: validateRoomName(roomText.text),
                        ),
                        onChanged: (text){
                          var status = false;
                          if(text != null && text.trim() != "" && nameText.text != null && nameText.text.trim() != "")
                            status = true;
                          setState(() {
                            enableJoinMeeting = status;
                          });
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextField(
                        controller: nameText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Display Name *",
                          hintText: "Enter Display Name",
                        ),
                        onChanged: (text){
                          var status = false;
                          if(text != null && text.trim() != "" && roomText.text != null && roomText.text.trim() != "")
                            status = true;
                          setState(() {
                            enableJoinMeeting = status;
                          });
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      /*TextField(
                        controller: emailText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Email",
                          hintText: "Enter Email",
                        ),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),*/
                      CheckboxListTile(
                        title: Text("Audio Only"),
                        value: isAudioOnly,
                        onChanged: _onAudioOnlyChanged,
                      ),
                      SizedBox(
                        height: 0.0,
                      ),
                      CheckboxListTile(
                        title: Text("Audio Muted"),
                        value: isAudioMuted,
                        onChanged: _onAudioMutedChanged,
                      ),
                      SizedBox(
                        height: 0.0,
                      ),
                      CheckboxListTile(
                        title: Text("Video Muted"),
                        value: isVideoMuted,
                        onChanged: _onVideoMutedChanged,
                      ),
                      Divider(
                        height: 48.0,
                        thickness: 2.0,
                      ),
                      SizedBox(
                        height: 64.0,
                        width: double.maxFinite,
                        child: RaisedButton(
                          onPressed: !enableJoinMeeting ? null : () {
                            _joinMeeting();
                          },
                          child: Text(
                            "Join Meeting",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(
                        height: 48.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    /*String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;*/
    String serverUrl = "https://sammelan.bel.co.in/";
    String dispName = nameText.text;

    if(dispName == null || dispName == ""){
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if(Platform.isAndroid){
        await deviceInfoPlugin.androidInfo.then((build){
          dispName = build.id;
        });
      } else if(Platform.isIOS){
        await deviceInfoPlugin.iosInfo.then((build){
          dispName = build.systemName;
        });
      }
    }


    try {
      var options = JitsiMeetingOptions()
        ..room = roomText.text
        ..serverURL = serverUrl
        //..subject = subjectText.text
        ..userDisplayName = nameText.text
        ..userEmail = emailText.text
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted;

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(options,
          listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
            debugPrint("${options.room} will join with message: $message");
          }, onConferenceJoined: ({message}) {
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: ({message}) {
            debugPrint("${options.room} terminated with message: $message");
          }));
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}