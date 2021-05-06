import 'package:quake/models/waveform_data_model.dart';
import 'package:vibration/vibration.dart';
import 'package:quake/helpers/waveform_data_loader.dart';
import 'package:quake/components/constants.dart';
import 'dart:math' as math;

class QuakeBrain {
  Song song;

  WaveformData _wave;
  List<int> _songPattern = [];
  List<int> _intensityPattern = [];

  QuakeBrain({this.song});

  int getSongLength() {
    return _wave.length;
  }

  Future initialize() async {
    _wave = await loadWaveformData(song.songBeatsPath);
  }

  bool _shouldPlay(double dataPoint, double threshold) {
    if (threshold == null || threshold == 0) threshold = kThreshold;
    return dataPoint.abs() >= threshold;
  }

  void vibrate({int startFrom, double intensity, double threshold}) async {
    if (intensity <= 0) return;

    int startingDataPoint = (startFrom / durationOfDatapoint).round();
    _songPattern.clear();
    _intensityPattern.clear();
    if (await Vibration.hasVibrator()) {
      List<double> dataPoints = _wave.scaledData();
      int countPlaying = 0;
      int countDelays = 0;

      for (int i = startingDataPoint; i < dataPoints.length; i += 2) {
        countDelays = 0;
        while (!_shouldPlay(dataPoints[i], threshold)) {
          countDelays += durationOfDatapoint;
          i += 2;
          if (i >= dataPoints.length) {
            break;
          }
        }
        _songPattern.add(countDelays);
        if (i >= dataPoints.length) {
          break;
        }

        countPlaying = 0;
        while (_shouldPlay(dataPoints[i], threshold)) {
          countPlaying += durationOfDatapoint;
          i += 2;
          if (i >= dataPoints.length) {
            break;
          }
        }
        _songPattern.add(countPlaying);
        // _intensityPattern.add((dataPoints[i - 1].abs() * 255).round());
      }
/*
      for (int i = startingDataPoint; i < dataPoints.length; i+=2) {
        _intensityPattern.add((dataPoints[i].abs() * 255).round());
      }*/

      int max = _songPattern.reduce(math.max);

      Vibration.vibrate(
        pattern: _songPattern,
        /*intensities: _songPattern
            .map((e) => e.abs() * (255 * intensity / 100) ~/ max)
            .toList(),*/
        //amplitude: 1,
      );
    }
  }

  void stopVibration() {
    Vibration.cancel();
  }
}
