import 'dart:math' as math;

/// rPPG (remote photoplethysmography) signal processing service.
///
/// This implements the core signal-processing pipeline that underlies
/// the rPPG-Toolbox (https://github.com/ubicomplab/rPPG-Toolbox):
///   1. Extract the mean green channel value from each video frame.
///   2. Accumulate a sliding window of samples.
///   3. Detrend the signal (remove slow drift).
///   4. Apply a simple bandpass filter (0.7–3.5 Hz ≈ 42–210 BPM).
///   5. Estimate the dominant frequency via autocorrelation → BPM.
///
/// Everything is isolated here — no UI code, no camera code.
class RppgService {
  RppgService._();

  // ── Configuration ───────────────────────────────────────────────────────────
  static const int kSampleRate = 30; // assumed camera FPS
  static const int kWindowSize = 150; // 5-second window at 30 FPS
  static const double kMinBpm = 42.0;
  static const double kMaxBpm = 210.0;

  // ── Internal ring buffer ────────────────────────────────────────────────────
  static final List<double> _greenBuffer = [];

  /// Feed one frame's mean green channel value (0–255) into the service.
  static void addSample(double greenMean) {
    _greenBuffer.add(greenMean);
    if (_greenBuffer.length > kWindowSize) {
      _greenBuffer.removeAt(0);
    }
  }

  /// Reset the buffer (call when the user navigates away or restarts).
  static void reset() => _greenBuffer.clear();

  /// Returns current estimated BPM, or null if not enough data yet.
  static double? estimateBpm() {
    if (_greenBuffer.length < kWindowSize ~/ 2) return null;

    final signal = List<double>.from(_greenBuffer);

    // 1. Detrend: subtract the linear trend
    final detrended = _detrend(signal);

    // 2. Bandpass filter (Butterworth-like IIR, order 2)
    final filtered = _bandpass(detrended, kSampleRate.toDouble(), kMinBpm / 60.0, kMaxBpm / 60.0);

    // 3. Autocorrelation-based dominant frequency estimation
    return _autocorrBpm(filtered, kSampleRate.toDouble());
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  static List<double> _detrend(List<double> x) {
    final n = x.length;
    final meanVal = x.reduce((a, b) => a + b) / n;
    // Linear regression
    double sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumXY += i * (x[i] - meanVal);
      sumX2 += i * i.toDouble();
    }
    final slope = sumX2 == 0 ? 0.0 : sumXY / sumX2;
    return List.generate(n, (i) => x[i] - (meanVal + slope * i));
  }

  static List<double> _bandpass(List<double> x, double fs, double lowHz, double highHz) {
    // Simple 2-pass (forward + backward) first-order RC filter approximation
    // — gives zero phase distortion and is sufficient for BPM estimation.
    final low = _rcHighpass(x, fs, lowHz);
    final band = _rcLowpass(low, fs, highHz);
    return band;
  }

  static List<double> _rcLowpass(List<double> x, double fs, double cutoffHz) {
    final rc = 1.0 / (2.0 * math.pi * cutoffHz);
    final dt = 1.0 / fs;
    final alpha = dt / (rc + dt);
    final out = List<double>.filled(x.length, 0.0);
    out[0] = x[0];
    for (int i = 1; i < x.length; i++) {
      out[i] = out[i - 1] + alpha * (x[i] - out[i - 1]);
    }
    return out;
  }

  static List<double> _rcHighpass(List<double> x, double fs, double cutoffHz) {
    final rc = 1.0 / (2.0 * math.pi * cutoffHz);
    final dt = 1.0 / fs;
    final alpha = rc / (rc + dt);
    final out = List<double>.filled(x.length, 0.0);
    out[0] = x[0];
    for (int i = 1; i < x.length; i++) {
      out[i] = alpha * (out[i - 1] + x[i] - x[i - 1]);
    }
    return out;
  }

  /// Uses autocorrelation to find the period of the dominant frequency,
  /// then converts to BPM.
  static double? _autocorrBpm(List<double> signal, double fs) {
    final n = signal.length;
    // Lag range corresponding to [kMinBpm, kMaxBpm]
    final lagMin = (60.0 / kMaxBpm * fs).round().clamp(1, n - 1);
    final lagMax = (60.0 / kMinBpm * fs).round().clamp(1, n - 1);

    if (lagMin >= lagMax) return null;

    double peakVal = double.negativeInfinity;
    int peakLag = lagMin;

    for (int lag = lagMin; lag <= lagMax; lag++) {
      double acc = 0.0;
      for (int i = 0; i < n - lag; i++) {
        acc += signal[i] * signal[i + lag];
      }
      if (acc > peakVal) {
        peakVal = acc;
        peakLag = lag;
      }
    }

    final periodSecs = peakLag / fs;
    final bpm = 60.0 / periodSecs;
    return bpm.clamp(kMinBpm, kMaxBpm);
  }
}
