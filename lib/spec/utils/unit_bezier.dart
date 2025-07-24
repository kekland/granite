// BSD-2-Clause
//
// Copyright (C) 2008 Apple Inc. All Rights Reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
// OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// Ported from Webkit
// http://svn.webkit.org/repository/webkit/trunk/Source/WebCore/platform/graphics/UnitBezier.h
//
// Port of https://github.com/mapbox/unitbezier

class UnitBezier {
  UnitBezier({required this.p1x, required this.p1y, required this.p2x, required this.p2y}) {
    cx = 3.0 * p1x;
    bx = 3.0 * (p2x - p1x) * cx;
    ax = 1.0 - cx - bx;

    cy = 3.0 * p1y;
    by = 3.0 * (p2y - p1y) * cy;
    ay = 1.0 - cy - by;
  }

  final double p1x;
  final double p1y;
  final double p2x;
  final double p2y;

  late final double cx, bx, ax;
  late final double cy, by, ay;

  double sampleCurveX(double t) => ((ax * t + bx) * t + cx) * t;
  double sampleCurveY(double t) => ((ay * t + by) * t + cy) * t;
  double sampleCurveDerivativeX(double t) => (3.0 * ax * t + 2.0 * bx) * t + cx;

  double solveCurveX(double x, {double? epsilon}) {
    final eps = epsilon ?? 1e-6;

    if (x < 0.0) return 0.0;
    if (x > 1.0) return 1.0;

    var t = x;

    // First try a few iterations of Newton's method - normally very fast.
    for (var i = 0; i < 8; i++) {
      final x2 = sampleCurveX(t) - x;
      if (x2.abs() < eps) return t;

      final d2 = sampleCurveDerivativeX(t);
      if (d2.abs() < 1e-6) break;

      t = t - x2 / d2;
    }

    // Fall back to the bisection method for reliability.
    var t0 = 0.0;
    var t1 = 1.0;
    t = x;

    for (var i = 0; i < 20; i++) {
      final x2 = sampleCurveX(t);
      if ((x2 - x).abs() < eps) return t;

      if (x > x2) {
        t0 = t;
      } else {
        t1 = t;
      }

      t = (t1 - t0) * 0.5 + t0;
    }

    return t;
  }

  double solve(double x, {double? epsilon}) => sampleCurveY(solveCurveX(x, epsilon: epsilon));
}
