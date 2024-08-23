import 'dart:io';

//import 'package:lua_dardo/lua.dart';
import 'package:lua/lua.dart';
import 'package:lua/sprintf.dart';

const String progname = "lua"; //LUA_PROGNAME;

const bool debug = false;
ThreadStatus docall_(LuaState? L, int narg, int nres) {
  ThreadStatus status;
  int base_ = L!.getTop() - narg; /* function index */
  status = L.pCall(narg, nres, base_);
  return status;
}

void lMessage_(String? pname, String? msg) {
  //		public static void luai_writestringerror(CharPtr s, object p) {
  //fprintf(stderr, s, p); fflush(stderr); }
  if (pname != null) {
    stderr.write(sprintf("%s: ", pname));
    stderr.flush();
  }
  stderr.write(sprintf("%s\n", msg));
  stderr.flush();
}

LuaState? l_;
String? dolua_(String message) {
  if (debug) {
    stdout.write(sprintf("%s\n", "==============>$message"));
  }
  if (l_ == null) {
    l_ = LuaState.newState(); //Lua.luaL_newstate();
    l_!.openLibs(); //Lua.luaL_openlibs(L_);
  }

  if (debug) {
    stdout.write(sprintf("%s\n", "==============>2"));
  }

  String? output;
  bool printResult = true;
  ThreadStatus status = l_!.loadString(message);
  if (status == ThreadStatus.luaOk) {
    if (debug) {
      stdout.write(sprintf("%s\n", "==============>3"));
    }
    status = docall_(l_, 0, printResult ? luaMultret : 0);
  }
  if ((status != ThreadStatus.luaOk) && !l_!.isNil(-1)) {
    if (debug) {
      stdout.write(sprintf("%s\n", "==============>4"));
    }
    String? msg = l_!.toString2(-1);
    msg ??= "(error object is not a string)";
    output = msg.toString();
    l_!.pop(1);
    /* force a complete garbage collection in case of errors */
    //Lua.lua_gc(L_, Lua.LUA_GCCOLLECT, 0);
  }
  if (printResult) {
    //see Lua.LUA_MULTRET
    if (status == ThreadStatus.luaOk && l_!.getTop() > 0) {
      /* any result to print? */
      l_!.checkStack2(luaMinStack, "too many results to print");
      l_!.getGlobal("print");
      l_!.insert(1);
      if (l_!.pCall(l_!.getTop() - 1, 0, 0) != ThreadStatus.luaOk) {
        //public static CharPtr LUA_QL(string x)	{return "'" + x + "'";}
        l_!.pushFString("error calling 'print' (%s)", [l_!.toString2(-1)!]);
        lMessage_(progname, l_!.toStr(-1));
      }
    }
  }

  return output;
}

int main_(List<String> args) {
  stdout.write(sprintf("%s\n", ["hello"]));
  String? result;
  result = dolua_("a = 100");
  if (result != null) {
    stdout.write(sprintf("%s\n", [result]));
  }
  result = dolua_("print(a)");
  if (result != null) {
    stdout.write(sprintf("%s\n", [result]));
  }
  return 0;
}

int main_2(List<String> args) {
  String? result;
  //stdin.echoMode = true;
  //stdin.echoNewlineMode = false;
  while (true) {
    //stdout.flush();
    stdout.write(sprintf("%s", ["> "]));
    String? line = stdin.readLineSync();
    if (line != null) {
      try {
        result = dolua_(line);
        if (result != null) {
          stdout.write(sprintf("%s\n", [result]));
        }
      } catch (e) {
        print(e);
      }
    } else {
      break;
    }
  }
  return 0;
}

void main(List<String> arguments) {
  main_2(arguments);
}

void main2(List<String> arguments) {
  LuaState state = LuaState.newState();
  state.openLibs();
  state.loadString(r'''
a=10
while( a < 20 ) do
   print("a value is", a)
   a = a+1
end
''');
  state.call(0, 0);
}
