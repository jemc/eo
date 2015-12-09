// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

use "collections"

interface iso StorageFetchSuccessLambda
  fun ref apply(sender: String, message: String) => None

interface iso StorageFetchFailureLambda
  fun ref apply() => None

actor Storage
  let _log: Log
  let _opts: Opts
  let _map: Map[String, List[(String, String)]]
  
  new create(log: Log, opts: Opts) =>
    _log = log
    _opts = opts
    _map = _map.create()
  
  be store(sender: String, recipient: String, message: String) =>
    (try _map(recipient) else
      let list = List[(String, String)]
      _map(recipient) = list
      list
    end).push((sender, message))
  
  be fetch(recipient: String, f_success: StorageFetchSuccessLambda,
                              f_failure: StorageFetchFailureLambda) =>
    try (let sender, let message) = _map(recipient).shift()
      (consume f_success)(sender, message)
    else
      (consume f_failure)()
    end
