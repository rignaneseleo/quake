import 'package:flutter/material.dart';

const int datapointsPerSecond = 172;
const Color primary_pink = Colors.orange;
const Color primary_black = Colors.black12;
const double kThreshold = 0.06;
final int durationOfDatapoint = (1000 / datapointsPerSecond).round();

class Lyric {
  int start, end;
  String title;

  Lyric({this.start, this.title, this.end});
}

class Song {
  String songName, artistName, songPath, songBeatsPath, imageUrl;
  List<Lyric> lyrics;
  double offset;
  double threshold;

  Song({
    this.songName,
    this.songPath,
    this.artistName,
    this.songBeatsPath,
    this.lyrics,
    this.offset = 0,
    this.threshold = kThreshold,
    this.imageUrl,
  });
}

List<Song> playList = [
  Song(
      songName: 'Highway to Hell',
      artistName: 'AC/DC',
      songPath: 'songs/highway.mp3',
      songBeatsPath: 'assets/waveforms/highway.json',
      imageUrl:
          "https://cdns-images.dzcdn.net/images/cover/de48d988a82fc401f4b9bafc2639f7d0/500x500-000000-80-0-0.jpg",
      offset: 10,
      lyrics: [
        Lyric(start: 0, end: 18130, title: "..."),
        Lyric(start: 18131, end: 22380, title: "Living easy‚ living free."),
        Lyric(
            start: 22381,
            end: 23380,
            title: "Season ticket on a one way ride."),
        Lyric(start: 23380, end: 30630, title: "Asking nothing‚ leave me be."),
        Lyric(
            start: 30631, end: 34630, title: "Taking everything in my stride."),
        Lyric(
            start: 34631,
            end: 38880,
            title: "Don′t need reason‚ don′t need rhyme."),
        Lyric(
            start: 38881,
            end: 42880,
            title: "Ain′t nothing I would rather do."),
        Lyric(start: 42881, end: 47130, title: "Goin' down, Party time."),
        Lyric(
            start: 47131,
            end: 52380,
            title: "My friends are gonna be there too."),
        Lyric(start: 52380, end: 56880, title: "I’m on the Highway to Hell."),
        Lyric(start: 56881, end: 61130, title: "On the Highway to Hell."),
        Lyric(start: 61131, end: 64630, title: "Highway to Hell"),
        Lyric(start: 64631, end: 67130, title: "I’m on the Highway to Hell."),
        Lyric(start: 67131, end: 71880, title: "..."),
        Lyric(start: 71881, end: 76130, title: "No stop signs, Speed limit."),
        Lyric(start: 76131, end: 80130, title: "Nobody's gonna slow me down."),
        Lyric(start: 80131, end: 84380, title: "Like a wheel, Gonna spin it."),
        Lyric(
            start: 84381, end: 88380, title: "Nobody's gonna mess me around."),
        Lyric(start: 88381, end: 93260, title: "Hey Satan, Payin' my dues."),
        Lyric(start: 93261, end: 96760, title: "Playing in a rocking band."),
        Lyric(start: 96760, end: 99010, title: "Hey mama."),
        Lyric(start: 99010, end: 101260, title: "Look at me."),
        Lyric(
            start: 101261,
            end: 106270,
            title: "I’m on the way to the promised land."),
        Lyric(start: 106271, end: 110770, title: "I’m on the Highway to Hell."),
        Lyric(start: 110771, end: 114520, title: "Highway to Hell"),
        Lyric(start: 114521, end: 119020, title: "I’m on the Highway to Hell."),
        Lyric(start: 119021, end: 125770, title: "Highway to Hell."),
        Lyric(start: 125771, end: 127520, title: "Don't stop me."),
        Lyric(start: 127521, end: 147770, title: "..."),
        Lyric(start: 147771, end: 152020, title: "I’m on the Highway to Hell."),
        Lyric(start: 152021, end: 155770, title: "On the Highway to Hell."),
        Lyric(start: 155771, end: 159650, title: "Highway to Hell"),
        Lyric(start: 159651, end: 164540, title: "I’m on the Highway to Hell."),
        Lyric(start: 161541, end: 167040, title: "(Highway to Hell)"),
        Lyric(start: 167041, end: 168540, title: "I’m on the Highway to Hell"),
        Lyric(start: 168541, end: 171540, title: "(Highway to Hell)"),
        Lyric(start: 175541, end: 176790, title: "Highway to Hell"),
        Lyric(start: 176791, end: 180930, title: "(Highway to Hell)"),
        Lyric(start: 180931, end: 186680, title: "And I’m going down"),
        Lyric(start: 186681, end: 202430, title: "All the way"),
        Lyric(start: 202430, end: 205930, title: "I’m on the Highway to Hell."),
        Lyric(start: 205931, end: 208000, title: "..."),
      ]),
  Song(
      songName: 'Another One Bites the Dust',
      artistName: 'Queen',
      songPath: 'songs/dust.mp3',
      songBeatsPath: 'assets/waveforms/dust.json',
      lyrics: [],
      offset: -8,
      imageUrl:
          "https://cdns-images.dzcdn.net/images/cover/8b8fc5d117f9357b79f0a0a410a170e8/500x500-000000-80-0-0.jpg"),
  Song(
    songName: 'Sweet Home Alabama',
    artistName: 'Lynyrd Skynyrd',
    songPath: 'songs/alabama.mp3',
    songBeatsPath: 'assets/waveforms/alabama.json',
    imageUrl:
        "https://cdns-images.dzcdn.net/images/cover/cb4c2efc2d1f2877ae6457d1feddc31b/500x500-000000-80-0-0.jpg",
    lyrics: [],
    offset: 5,
  ),
  Song(
    songName: 'Good Times Bad Times ',
    artistName: 'Led Zeppelin',
    songPath: 'songs/good.mp3',
    songBeatsPath: 'assets/waveforms/good.json',
    imageUrl:
        "https://cdns-images.dzcdn.net/images/cover/e7e504911214f3ce512fecf78f42fbed/500x500-000000-80-0-0.jpg",
    lyrics: [],
    offset: 30,
  ),
  Song(
    songName: 'London Calling',
    artistName: 'The Clash',
    songPath: 'songs/london.mp3',
    songBeatsPath: 'assets/waveforms/london.json',
    imageUrl:
        "https://cdns-images.dzcdn.net/images/cover/1dbb7d7bee08ed2b18deabffd675bd36/500x500-000000-80-0-0.jpg",
    lyrics: [],
    offset: 7,
    threshold: 0.09,
  ),
];

String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}
