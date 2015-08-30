// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

use zmq = "../../pony-zmq/zmq"

actor Service is zmq.SocketNotifiableActor
  let _log: Log
  let _opts: Opts
  let _socket: zmq.Socket
  let _storage: Storage
  
  new create(log: Log, opts: Opts) =>
    _log = log
    _opts = opts
    _socket = zmq.Socket(zmq.REP, zmq.SocketNotifyActor(this))
    _storage = Storage(log, opts)
    
    _log.notice("eo service starting\n"+
                "on port: "+_opts.port)
    
    _socket.bind("tcp://localhost:"+_opts.port)
  
  be received(s: zmq.Socket, p: zmq.SocketPeer, m: zmq.Message) =>
    let iter = m.values()
    try
      match iter.next()
      | "get"  => received_get(p)
      | "send" => received_send(p, iter.next(), iter.next())
      else error
      end
    else
      _log.warn("received unknown protocol message: "+m.string())
      p.send(recover zmq.Message.push("error") end)
    end
  
  fun received_get(p: zmq.SocketPeer) =>
    let sender = "sender" // TODO: get sender public key from zmq.SocketPeer
    _storage.fetch(sender, recover lambda(p: zmq.SocketPeer, s: String, m: String) =>
      p.send(recover zmq.Message.push("got").push(s).push(m) end)
    end~apply(p) end, recover lambda(p: zmq.SocketPeer) =>
      p.send(recover zmq.Message.push("none") end)
    end~apply(p) end)
  
  fun received_send(p: zmq.SocketPeer, recipient: String, message: String) =>
    let sender = "sender" // TODO: get sender public key from zmq.SocketPeer
    _storage.store(sender, recipient, message)
    p.send(recover zmq.Message.push("sent") end)
