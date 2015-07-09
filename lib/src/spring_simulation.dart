// Copyright (c) 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of newton;

class SpringDescription {
  /// The mass of the spring (m)
  final double mass;

  /// The spring constant (k)
  final double springConstant;

  /// The damping coefficient.
  /// Note: Not to be confused with the damping ratio. Use the separate
  ///       constructor provided for this purpose
  final double damping;

  SpringDescription({double mass, double springConstant, double damping})
      : mass = mass,
        springConstant = springConstant,
        damping = damping {
    assert(mass != null);
    assert(springConstant != null);
    assert(damping != null);
  }

  /// Create a spring given the mass, spring constant and the damping ratio. The
  /// damping ratio is especially useful trying to determing the type of spring
  /// to create. A ratio of 1.0 creates a critically damped spring, > 1.0
  /// creates an overdamped spring and < 1.0 an underdamped one.
  SpringDescription.withDampingRatio(
      {double mass, double springConstant, double ratio: 1.0})
      : mass = mass,
        springConstant = springConstant,
        damping = ratio * 2.0 * math.sqrt(mass * springConstant);
}

enum SpringType { unknown, criticallyDamped, underDamped, overDamped, }

/// Creates a spring simulation. Depending on the spring description, a
/// critically, under or overdamped spring will be created.
class SpringSimulation extends Simulation {
  final double _endPosition;

  final _SpringSolution _solution;

  /// A spring description with the provided spring description, start distance,
  /// end distance and velocity.
  SpringSimulation(
      SpringDescription desc, double start, double end, double velocity)
      : this._endPosition = end,
        _solution = new _SpringSolution(desc, start - end, velocity);

  SpringType get type => _solution.type;

  double x(double time) => _endPosition + _solution.x(time);

  double dx(double time) => _solution.dx(time);

  @override
  bool isDone(double time) =>
      _nearEqual(x(time), _endPosition) && _nearZero(dx(time));
}
