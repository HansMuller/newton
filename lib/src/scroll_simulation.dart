// Copyright (c) 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of newton;

/// Simulates kinetic scrolling behavior between a leading and trailing
/// boundary. Friction is applied within the extends and a spring action applied
/// at the boundaries. This simulation can only step forward.
class ScrollSimulation extends SimulationGroup {
  final double _leadingExtent;
  final double _trailingExtent;
  final SpringDescription _springDesc;
  final double _drag;

  bool _isSpringing = false;
  Simulation _currentSimulation;
  double _offset = 0.0;

  ScrollSimulation(double position, double velocity, double leading,
      double trailing, SpringDescription spring, double drag)
      : _leadingExtent = leading,
        _trailingExtent = trailing,
        _springDesc = spring,
        _drag = drag {
    _chooseSimulation(position, velocity, 0.0);
  }

  @override
  bool step(double time) => _chooseSimulation(
      _currentSimulation.x(time - _offset),
      _currentSimulation.dx(time - _offset), time);

  @override
  Simulation get currentSimulation => _currentSimulation;

  @override
  double get currentIntervalOffset => _offset;

  bool _chooseSimulation(
      double position, double velocity, double intervalOffset) {

    /// This simulation can only step forward.
    if (!_isSpringing) {
      if (position > _trailingExtent) {
        _isSpringing = true;
        _offset = intervalOffset;
        _currentSimulation = new SpringSimulation(
            _springDesc, position, _trailingExtent, velocity);
        return true;
      } else if (position < _leadingExtent) {
        _isSpringing = true;
        _offset = intervalOffset;
        _currentSimulation = new SpringSimulation(
            _springDesc, position, _leadingExtent, velocity);
        return true;
      }
    }

    if (_currentSimulation == null) {
      _currentSimulation = new FrictionSimulation(_drag, position, velocity);
      return true;
    }

    return false;
  }
}
