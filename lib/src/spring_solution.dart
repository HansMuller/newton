// Copyright (c) 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of newton;

abstract class _SpringSolution implements Simulatable {
  factory _SpringSolution(
      SpringDesc desc, double initialPosition, double initialVelocity) {
    double cmk =
        desc.damping * desc.damping - 4 * desc.mass * desc.springConstant;

    if (cmk == 0.0) {
      return new _CriticalSolution(desc, initialPosition, initialVelocity);
    } else if (cmk > 0.0) {
      return new _OverdampedSolution(desc, initialPosition, initialVelocity);
    } else {
      return new _UnderdampedSolution(desc, initialPosition, initialVelocity);
    }

    return null;
  }
}

class _CriticalSolution implements _SpringSolution {
  final double _r, _c1, _c2;

  factory _CriticalSolution(SpringDesc desc, double distance, double velocity) {
    final double r = -desc.damping / (2.0 * desc.mass);
    final double c1 = distance;
    final double c2 = velocity / (r * distance);
    return new _CriticalSolution.withArgs(r, c1, c2);
  }

  _CriticalSolution.withArgs(double r, double c1, double c2)
      : _r = r,
        _c1 = c1,
        _c2 = c2;

  double x(double time) => (_c1 + _c2 * time) * Math.pow(Math.E, _r * time);

  double dx(double time) {
    final double power = Math.pow(Math.E, _r * time);
    return _r * (_c1 + _c2 * time) * power + _c2 * power;
  }
}

class _OverdampedSolution implements _SpringSolution {
  final double _r1, _r2, _c1, _c2;

  factory _OverdampedSolution(
      SpringDesc desc, double distance, double velocity) {
    final double cmk =
        desc.damping * desc.damping - 4 * desc.mass * desc.springConstant;

    final double r1 = (-desc.damping - Math.sqrt(cmk)) / (2.0 * desc.mass);
    final double r2 = (-desc.damping + Math.sqrt(cmk)) / (2.0 * desc.mass);
    final double c2 = (velocity - r1 * distance) / (r2 - r1);
    final double c1 = distance - c2;

    return new _OverdampedSolution.withArgs(r1, r2, c1, c2);
  }

  _OverdampedSolution.withArgs(double r1, double r2, double c1, double c2)
      : _r1 = r1,
        _r2 = r2,
        _c1 = c1,
        _c2 = c2;

  double x(double time) =>
      (_c1 * Math.pow(Math.E, _r1 * time) + _c2 * Math.pow(Math.E, _r2 * time));

  double dx(double time) => (_c1 * _r1 * Math.pow(Math.E, _r1 * time) +
      _c2 * _r2 * Math.pow(Math.E, _r2 * time));
}

class _UnderdampedSolution implements _SpringSolution {
  final double _w, _r, _c1, _c2;

  factory _UnderdampedSolution(
      SpringDesc desc, double distance, double velocity) {
    final double w = Math.sqrt(4.0 * desc.mass * desc.springConstant -
            desc.damping * desc.damping) /
        (2.0 * desc.mass);
    final double r = -(desc.damping / 2.0 * desc.mass);
    final double c1 = distance;
    final double c2 = (velocity - r * distance) / w;

    return new _UnderdampedSolution.withArgs(w, r, c1, c2);
  }

  _UnderdampedSolution.withArgs(double w, double r, double c1, double c2)
      : _w = w,
        _r = r,
        _c1 = c1,
        _c2 = c2;

  double x(double time) => Math.pow(Math.E, _r * time) *
      (_c1 * Math.cos(_w * time) + _c2 * Math.sin(_w * time));

  double dx(double time) {
    final double power = Math.pow(Math.E, _r * time);
    final double cosine = Math.cos(_w * time);
    final double sine = Math.sin(_w * time);

    return power * (_c2 * _w * cosine - _c1 * _w * sine) +
        _r * power * (_c2 * sine + _c1 * cosine);
  }
}
