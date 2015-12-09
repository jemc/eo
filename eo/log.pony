// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

use "time"

trait val LogLevel
  fun tag value(): U8
  fun tag string(): String

primitive LogCritical is LogLevel fun tag string(): String => "C" fun tag value(): U8 => 2
primitive LogError    is LogLevel fun tag string(): String => "E" fun tag value(): U8 => 3
primitive LogWarning  is LogLevel fun tag string(): String => "W" fun tag value(): U8 => 4
primitive LogNotice   is LogLevel fun tag string(): String => "N" fun tag value(): U8 => 5
primitive LogInfo     is LogLevel fun tag string(): String => "I" fun tag value(): U8 => 6
primitive LogDebug    is LogLevel fun tag string(): String => "D" fun tag value(): U8 => 7

actor Log
  let _env: Env
  let _max_level: LogLevel
  
  new create(env: Env, max_level: LogLevel = LogDebug) =>
    _env = env
    _max_level = max_level
  
  be apply(l: LogLevel, s: String) => _log(l, s)
  
  be crit   (s: String) => _log(LogCritical, s)
  be err    (s: String) => _log(LogError,    s)
  be warn   (s: String) => _log(LogWarning,  s)
  be notice (s: String) => _log(LogNotice,   s)
  be info   (s: String) => _log(LogInfo,     s)
  be debug  (s: String) => _log(LogDebug,    s)
  
  be out  (s: String)            => _env.out.print(s)
  be outv (a: Array[String] val) => _env.out.printv(a)
  
  fun tag _time(): String =>
    Date(Time.seconds()).format("%Y-%m-%dT%H:%M:%S")
  
  fun _log(level: LogLevel, string: String) =>
    if level.value() > _max_level.value() then return end
    
    var sep = " > "
    let log_lines = recover trn Array[String] end
    for line in string.split("\n").values() do
      log_lines.push(level.string()+" | "+_time()+sep+line)
      sep = "   "
    end
    
    _env.err.printv(consume log_lines)
