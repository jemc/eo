// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

use o = "options"

class val Opts
  var service:   Bool   = false
  var get:       Bool   = false
  var host:      String = "localhost"
  var port:      String = "25967"
  var message:   String = ""
  var recipient: String = ""
  
  new val create(env: Env) =>
    let options = o.Options(env)
      .add("service",   "s")
      .add("get",       "g")
      .add("host",      "h", o.StringArgument)
      .add("port",      "p", o.StringArgument)
      .add("message",   "m", o.StringArgument)
      .add("recipient", "r", o.StringArgument)
    
    for option in options do
      match option
      | ("service",   _)             => service   = true
      | ("get",       _)             => get       = true
      | ("host",      let x: String) => host      = x
      | ("port",      let x: String) => port      = x
      | ("message",   let x: String) => message   = x
      | ("recipient", let x: String) => recipient = x
      end
    end
