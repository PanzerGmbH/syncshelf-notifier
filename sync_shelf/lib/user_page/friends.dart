import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'friends_model.dart';
import 'friend_requests.dart'; // Import der neuen Seite für Freundschaftsanfragen
export 'friends_model.dart';

class FriendsWidget extends StatefulWidget {
  const FriendsWidget({super.key});

  static String routeName = 'friends';
  static String routePath = '/friends';

  @override
  State<FriendsWidget> createState() => _FriendsWidgetState();
}

class _FriendsWidgetState extends State<FriendsWidget> {
  late FriendsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FriendsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF1F4F8),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional(0, -1),
                child: Container(
                  width: 350,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0x00FFFFFF),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Stack(
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1, 0),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0x00FFFFFF),
                              shape: BoxShape.rectangle,
                            ),
                            child: FlutterFlowIconButton(
                              borderRadius: 8,
                              buttonSize: 40,
                              fillColor: Color(0x004B39EF),
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 24,
                              ),
                              onPressed: () {
                                context.go('/user'); // Zurück zur vorherigen Seite
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Text(
                            'Friends',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              fontFamily: 'Inter',
                              fontSize: 50,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0000D6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0, -0.55),
                child: Icon(
                  Icons.people_alt,
                  color: Color(0xFF0000D6),
                  size: 200,
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0, 1.4),
                child: Container(
                  width: 350,
                  height: 600, // Größe des Containers leicht erhöht für den dritten Button
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Gleichmäßige Verteilung
                    children: [
                      // 🔹 View Friend List Button
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.go('/friendList');
                        },
                        child: Container(
                          width: 300,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0x00FFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF070000),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'View friend list',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Inter',
                                fontSize: 26,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 🔹 Add New Friends Button
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.go('/addFriend');
                        },
                        child: Container(
                          width: 300,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0x00FFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF070000),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Add new friends',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Inter',
                                fontSize: 26,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 🔹 View Friend Requests Button
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FriendRequestsPage()),
                          );
                        },
                        child: Container(
                          width: 300,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0x00FFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF070000),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'View friend requests',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Inter',
                                fontSize: 26,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
