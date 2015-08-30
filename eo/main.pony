// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

actor Main
  new create(env: Env) =>
    let log = Log(env)
    let opts = Opts(env)
    
    if opts.service then
      Service(log, opts)
    else
      Client(log, opts)
    end
