import '../number/lua_math.dart';

class FPB {
  /*
     ** converts an integer to a "floating point byte", represented as
     ** (eeeeexxx), where the real value is (1xxx) * 2^(eeeee - 1) if
     ** eeeee != 0 and (xxx) otherwise.
     */
  static int int2fb(int x) {
    int e = 0; /* exponent */
    if (x < 8) {
      return x;
    }
    while (x >= (8 << 4)) {
      /* coarse steps */
      x = (x + 0xf) >> 4; /* x = ceil(x / 16) */
      e += 4;
    }
    while (x >= (8 << 1)) {
      /* fine steps */
      x = (x + 1) >> 1; /* x = ceil(x / 2) */
      e++;
    }
    return LuaMath.toInt32((e + 1) << 3) | (x - 8);
  }

  /* converts back */
  static int fb2int(int x) {
    if (x < 8) {
      return x;
    } else {
      return LuaMath.toInt32(((x & 7) + 8) << ((x >> 3) - 1));
    }
  }
}
