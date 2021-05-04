import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quake/components/constants.dart';
import 'package:quake/components/buttons.dart';
import 'package:quake/components/music_slider.dart';
import 'package:quake/views/widget/volume_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quake/models/quake_brain.dart';

class Player extends StatefulWidget {
  static const String id = 'player';
  int songNumber;

  Player({@required this.songNumber});

  @override
  _PlayerState createState() => _PlayerState(songNumber: songNumber);
}

class _PlayerState extends State<Player> {
  _PlayerState({@required this.songNumber});

  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();
  Stopwatch stopwatch = Stopwatch();
  QuakeBrain brain = new QuakeBrain();
  int songNumber;
  bool playing = false;

  double vibrationIntensity = 99;
  double offset = 0;

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _playAudio() async {
    var bytes = await (await audioCache.load(playList[songNumber].songPath))
        .readAsBytes();
    await audioPlayer.playBytes(bytes,
        position: Duration(
            milliseconds: stopwatch.elapsedMilliseconds + offset.toInt()));
    brain.vibrate(
        startFrom: stopwatch.elapsedMilliseconds,
        intensity: vibrationIntensity);
    stopwatch.start();
  }

  Future<void> _pauseAudio() async {
    await audioPlayer.pause();
    brain.stopVibration();
    stopwatch.stop();
  }

  Future<void> _resetAudio() async {
    brain.stopVibration();
    stopwatch.reset();
    stopwatch.stop();
    await audioPlayer.stop();
  }

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      setState(() {});
    });
    super.initState();
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
        body: Stack(children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                /*Expanded(
                  child: Container(
                    color: primary_pink,
                  ),
                ),*/
                Expanded(
                  child: Container(
                    color: primary_black,
                  ),
                )
              ]),
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 20.0),
              Text(
                songTitle,
                style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.white,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  MusicSlider(
                    progress: stopwatch.elapsedMilliseconds,
                    trackLength: brain.getSongLength(),
                  ),
                  Text(
                    printDuration(
                        Duration(milliseconds: stopwatch.elapsedMilliseconds)),
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                        decoration: TextDecoration.none),
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
              getLiveControls(),
              Container(height: 20),
            ],
          )),
        ]),
      ),
    );
  }

  getLiveControls() {
    return Column(
      children: [
        Text("Live controls"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.volume_down_rounded),
            VolumeSlider(
              display: Display.HORIZONTAL,
              sliderActiveColor: Colors.blue,
              sliderInActiveColor: Colors.grey,
            ),
            Icon(Icons.volume_up_rounded),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.phone_android_sharp),
            Slider(
              onChanged: (double value) async {
                vibrationIntensity = value;

                if (playing) {
                  await _pauseAudio();
                  await _playAudio();
                }
              },
              value: vibrationIntensity,
              max: 100,
              min: 0,
            ),
            Icon(Icons.vibration_rounded),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Slider(
              onChanged: (double value) async {
                setState(() {
                  offset = value;
                });
              },
              value: offset,
              max: 2000,
              min: 0,
            ),
            Text(offset.toInt().toString()),
          ],
        ),
      ],
    );
  }
}
