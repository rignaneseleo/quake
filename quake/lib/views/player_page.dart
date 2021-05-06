import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quake/components/constants.dart';
import 'package:quake/components/buttons.dart';
import 'package:quake/components/music_slider.dart';
import 'package:quake/views/widget/volume_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quake/models/quake_brain.dart';
import 'package:vibration/vibration.dart';

class PlayerPage extends StatefulWidget {
  static const String id = 'player';
  int songNumber;

  PlayerPage({@required this.songNumber});

  @override
  _PlayerPageState createState() => _PlayerPageState(songNumber: songNumber);
}

class _PlayerPageState extends State<PlayerPage> {
  _PlayerPageState({@required this.songNumber});

  bool isReady = false;

  Timer refresh;

  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();
  Stopwatch stopwatch = Stopwatch();
  QuakeBrain controller;
  int songNumber;
  bool playing = false;

  int songLength;
  double vibrationIntensity = 100;
  double delay = 0;
  int songDuration = 0;
  double threshold = kThreshold;
  Uint8List songBytes;

  bool showLiveControls = false;

  bool hasAmplitudeControl = null;

  @override
  void initState() {
    _load();

    refresh = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      setState(() {});
    });

    delay = playList[widget.songNumber].offset ?? 0;
    threshold = playList[widget.songNumber].threshold ?? kThreshold;

    super.initState();
  }

  _load() async {
    setState(() {
      isReady = false;
    });

    controller = new QuakeBrain(song: playList[widget.songNumber]);
    await controller.initialize();

    songLength = controller.getSongLength();

    hasAmplitudeControl = await Vibration.hasAmplitudeControl();

    songBytes = await (await audioCache.load(playList[songNumber].songPath))
        .readAsBytes();

    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => songDuration = d.inMilliseconds);
    });

    setState(() {
      isReady = true;
    });
  }

  @override
  void dispose() {
    _resetAudio();

    if (refresh != null) refresh.cancel();
    super.dispose();
  }

  Future<void> _playAudio() async {
    await audioPlayer.playBytes(songBytes,
        position: Duration(
            milliseconds: stopwatch.elapsedMilliseconds + delay.toInt() * 100));

    controller.vibrate(
      startFrom: stopwatch.elapsedMilliseconds,
      intensity: vibrationIntensity,
      threshold: threshold,
    );
    stopwatch.start();
  }

  Future<void> _pauseAudio() async {
    await audioPlayer.pause();
    controller.stopVibration();
    stopwatch.stop();
  }

  Future<void> _resetAudio() async {
    controller.stopVibration();
    stopwatch.reset();
    stopwatch.stop();
    await audioPlayer.stop();
  }

  String findLyrics() {
    int currentTime = stopwatch.elapsedMilliseconds;
    Lyric lyric;
    for (int i = 0; i < playList[songNumber].lyrics.length; i++) {
      lyric = playList[songNumber].lyrics[i];
      if (currentTime >= lyric.start && currentTime <= lyric.end) {
        return lyric.title;
      }
    }
    return '...';
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady)
      return Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text("The song is loading..."),
            ),
          ],
        ),
      ));

    String songTitle = playList[songNumber].songName;
    String artistName = playList[songNumber].artistName;

    return SafeArea(
      child: Scaffold(
        /* floatingActionButton: FloatingActionButton(
          onPressed: () {
            _launchURL('https://www.youtube.com/watch?v=l482T0yNkeo');
          },
          backgroundColor: Colors.black12,
          child: Image.asset(
            'assets/images/egg.png',
          ),
        ),*/
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 20.0),
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      child: Image.network(playList[songNumber].imageUrl ?? ""),
                    ),
                    Container(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          AutoSizeText(
                            songTitle,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 30.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Source Sans Pro',
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            artistName,
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                                decoration: TextDecoration.none),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              Text(
                findLyrics(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.orangeAccent,
                  decoration: TextDecoration.none,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Expanded(child: Container()),
              if (songDuration != 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      printDuration(Duration(
                          milliseconds: stopwatch.elapsedMilliseconds)),
                      style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          decoration: TextDecoration.none),
                    ),
                    MusicSlider(
                      progress: stopwatch.elapsedMilliseconds,
                      trackLength: songDuration,
                    ),
                  ],
                ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () async {
                          setState(() {
                            playing = !playing;
                          });

                          if (playing)
                            await _playAudio();
                          else
                            await _pauseAudio();
                        },
                        child: playing
                            ? PauseButton(
                                onPress: null,
                              )
                            : PlayButton(
                                onPress: null,
                              )),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          playing = false;
                        });
                        await _resetAudio();
                      },
                      child: ResetButton(),
                    )
                  ]),
              Container(height: 40),
              GestureDetector(
                child: Text("Live controls " + (showLiveControls ? "▲" : "▼"),
                    style: TextStyle(fontSize: 15.0)),
                onTap: () {
                  setState(() {
                    showLiveControls = !showLiveControls;
                  });
                },
              ),
              if (showLiveControls) buildLiveControls(),
              Container(height: 20),
            ],
          ),
        )),
      ),
    );
  }

  Widget buildLiveControls() {
    return Column(
      children: [
        buildVolume(),
        buildThreshold(),
        buildDelay(),
        buildVibration(),
      ],
    );
  }

  Widget buildVibration() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: IconButton(
                color: vibrationIntensity == 0 ? Colors.white : Colors.grey,
                icon: ImageIcon(
                  AssetImage("assets/icons/vibration_0.png"),
                  size: 30,
                ),
                onPressed: () async {
                  if (vibrationIntensity == 0) return;

                  setState(() {
                    vibrationIntensity = 0;
                  });

                  await _pauseAudio();
                  await _playAudio();
                },
              ),
            ),
            Expanded(
              child: IconButton(
                color: vibrationIntensity == 100 ? Colors.white : Colors.grey,
                icon: ImageIcon(
                  AssetImage("assets/icons/vibration_1.png"),
                  size: 30,
                ),
                onPressed: () async {
                  if (vibrationIntensity == 100) return;

                  setState(() {
                    vibrationIntensity = 100;
                  });

                  await _pauseAudio();
                  await _playAudio();
                },
              ),
            ),
            Expanded(
              child: IconButton(
                color: vibrationIntensity == 200 ? Colors.white : Colors.grey,
                icon: Icon(Icons.vibration_rounded, size: 30),
                onPressed: () async {
                  if (vibrationIntensity == 200) return;

                  if (!hasAmplitudeControl) {
                    Fluttertoast.showToast(
                      msg: "This device does not support this vibration",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    return;
                  }
                  setState(() {
                    vibrationIntensity = 200;
                  });

                  await _pauseAudio();
                  await _playAudio();
                },
              ),
            ),
          ],
        ),
      );

  Widget buildThreshold() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                "Threshold",
                textAlign: TextAlign.center,
              )),
          Flexible(
            flex: 3,
            child: Slider(
              activeColor: Colors.orange,
              onChanged: (double value) async {
                setState(() {
                  threshold = value;
                });
              },
              value: threshold,
              max: 0.30,
              min: 0.01,
            ),
          ),
          Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                threshold.toStringAsFixed(2),
                textAlign: TextAlign.center,
              )),
        ],
      );

  Widget buildDelay() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                "Delay",
                textAlign: TextAlign.center,
              )),
          Flexible(
            flex: 3,
            child: Slider(
              activeColor: Colors.orange,
              onChanged: (double value) async {
                setState(() {
                  delay = value;
                });
              },
              value: delay,
              max: 30,
              min: -30,
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(
              (delay / 10).toStringAsFixed(1) + "s",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );

  Widget buildVolume() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Icon(Icons.volume_down_rounded),
          ),
          Flexible(
            flex: 3,
            child: VolumeSlider(
              display: Display.HORIZONTAL,
              sliderActiveColor: Colors.orange,
              sliderInActiveColor: Colors.grey,
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Icon(Icons.volume_up_rounded),
          ),
        ],
      );
}
