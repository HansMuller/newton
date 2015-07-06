// Copyright (c) 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library simple_physics.test;

import 'package:test/test.dart';

import 'package:newton/newton.dart';

void main() {
  test('test_friction', () {
    var friction = new Friction(0.3, 100.0, 400.0);

    expect(friction.isDone(0.0), false);
    expect(friction.x(0.0), 100);
    expect(friction.dx(0.0), 400.0);

    expect(friction.x(1.0) > 330 && friction.x(1.0) < 335, true);

    expect(friction.dx(1.0), 120.0);
    expect(friction.dx(2.0), 36.0);
    expect(friction.dx(3.0), 10.8);
    expect(friction.dx(4.0) < 3.5, true);

    expect(friction.isDone(5.0), true);
    expect(friction.x(5.0) > 431 && friction.x(5.0) < 432, true);
  });

  test('test_gravity', () {
    var gravity = new Gravity(200.0, 100.0, 600.0, 0.0);

    expect(gravity.isDone(0.0), false);
    expect(gravity.x(0.0), 100.0);
    expect(gravity.dx(0.0), 0.0);

    // Starts at 100
    expect(gravity.x(0.25), 106.25);
    expect(gravity.x(0.50), 125);
    expect(gravity.x(0.75), 156.25);
    expect(gravity.x(1.00), 200);
    expect(gravity.x(1.25), 256.25);
    expect(gravity.x(1.50), 325);
    expect(gravity.x(1.75), 406.25);

    // Starts at 0.0
    expect(gravity.dx(0.25), 50.0);
    expect(gravity.dx(0.50), 100);
    expect(gravity.dx(0.75), 150.00);
    expect(gravity.dx(1.00), 200.0);
    expect(gravity.dx(1.25), 250.0);
    expect(gravity.dx(1.50), 300);
    expect(gravity.dx(1.75), 350);

    expect(gravity.isDone(2.5), true);
    expect(gravity.x(2.5), 725);
    expect(gravity.dx(2.5), 500.0);
  });

  test('spring_types', () {
    var crit = new Spring(
        new SpringDesc.withDampingRatio(1.0, 100.0, 1.0), 0.0, 300.0, 0.0);
    expect(crit.type, SpringType.criticallyDamped);

    var under = new Spring(
        new SpringDesc.withDampingRatio(1.0, 100.0, 0.75), 0.0, 300.0, 0.0);
    expect(under.type, SpringType.underDamped);

    var over = new Spring(
        new SpringDesc.withDampingRatio(1.0, 100.0, 1.25), 0.0, 300.0, 0.0);
    expect(over.type, SpringType.overDamped);

    // Just so we don't forget how to create a desc without the ratio.
    var other = new Spring(new SpringDesc(1.0, 100.0, 20.0), 0.0, 20.0, 20.0);
    expect(other.type, SpringType.criticallyDamped);
  });

  test('crit_spring', () {
    var crit = new Spring(
        new SpringDesc.withDampingRatio(1.0, 100.0, 1.0), 0.0, 500.0, 0.0);
    expect(crit.type, SpringType.criticallyDamped);

    expect(crit.isDone(0.0), false);
    expect(crit.x(0.0), 0.0);
    expect(crit.dx(0.0), 5000.0);

    expect(crit.x(0.25).floor(), 458.0);
    expect(crit.x(0.50).floor(), 496.0);
    expect(crit.x(0.75).floor(), 499.0);

    expect(crit.dx(0.25).floor(), 410);
    expect(crit.dx(0.50).floor(), 33);
    expect(crit.dx(0.75).floor(), 2);

    expect(crit.isDone(1.50), true);
    expect(crit.x(1.5) > 499.0 && crit.x(1.5) < 501.0, true);
    expect(crit.dx(1.5) < 0.1, true /* basically within tolerance */);
  });

  test('overdamped_spring', () {
    var over = new Spring(
        new SpringDesc.withDampingRatio(1.0, 100.0, 1.25), 0.0, 500.0, 0.0);
    expect(over.type, SpringType.overDamped);

    expect(over.isDone(0.0), false);
    expect(over.x(0.0), 0.0);

    expect(over.x(0.5).floor(), 445.0);
    expect(over.x(1.0).floor(), 495.0);
    expect(over.x(1.5).floor(), 499.0);

    expect(over.dx(0.5).floor(), 273.0);
    expect(over.dx(1.0).floor(), 22.0);
    expect(over.dx(1.5).floor(), 1.0);

    expect(over.isDone(3.0), true);
  });

  test('underdamped_spring', () {
    var under = new Spring(
        new SpringDesc.withDampingRatio(1.0, 100.0, 0.25), 0.0, 300.0, 0.0);
    expect(under.type, SpringType.underDamped);

    expect(under.isDone(0.0), false);

    // Overshot with negative velocity
    expect(under.x(1.0).floor(), 325);
    expect(under.dx(1.0).floor(), -65);

    expect(under.dx(6.0).floor(), 0.0);
    expect(under.x(6.0).floor(), 299);

    expect(under.isDone(6.0), true);
  });

  test('test_kinetic_scroll', () {
    var spring = new SpringDesc.withDampingRatio(1.0, 50.0, 0.5);

    var scroll = new Scroll(100.0, 800.0, 0.0, 300.0, spring, 0.3);

    expect(scroll.isDone(0.0), false);
    expect(scroll.isDone(3.5), true);

    var scroll2 = new Scroll(100.0, -800.0, 0.0, 300.0, spring, 0.3);
    expect(scroll2.isDone(4.5), true);
  });
}
