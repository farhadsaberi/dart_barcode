/*
 * Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ignore_for_file: omit_local_variable_types

import 'barcode.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';

class BarcodeCode93 extends Barcode {
  const BarcodeCode93();

  @override
  Iterable<int> get charSet => BarcodeMaps.code93.keys.where((int x) => x > 0);

  @override
  String get name => 'CODE 93';

  @override
  Iterable<bool> convert(String data) sync* {
    // Start
    yield* add(BarcodeMaps.code93StartStop, BarcodeMaps.code93Len);

    final List<int> keys = BarcodeMaps.code93.keys.toList();

    for (int code in data.codeUnits) {
      final int codeValue = BarcodeMaps.code93[code];
      if (codeValue == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }
      yield* add(codeValue, BarcodeMaps.code93Len);
    }

    // Checksum
    int sumC = 0;
    int sumK = 0;
    int indexC = 1;
    int indexK = 2;

    for (int index = data.codeUnits.length - 1; index >= 0; index--) {
      final int code = data.codeUnits[index];
      sumC += keys.indexOf(code) * indexC;
      sumK += keys.indexOf(code) * indexK;

      indexC++;
      if (indexC > 20) {
        indexC = 1;
      }
      indexK++;
      if (indexK > 15) {
        indexK = 1;
      }
    }

    sumC = sumC % 47;
    yield* add(BarcodeMaps.code93[keys[sumC]], BarcodeMaps.code93Len);

    sumK = (sumK + sumC) % 47;
    yield* add(BarcodeMaps.code93[keys[sumK]], BarcodeMaps.code93Len);

    // Stop
    yield* add(BarcodeMaps.code93StartStop, BarcodeMaps.code93Len);

    // Termination Bar
    yield true;
  }
}
