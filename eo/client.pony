// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

use zmq = "zmq"

actor Client is zmq.SocketNotifiableActor
  let _log: Log
  let _opts: Opts
  let _socket: zmq.Socket
  
  new create(log: Log, opts: Opts) =>
    _log = log
    _opts = opts
    _socket = zmq.Socket(zmq.REQ, zmq.SocketNotifyActor(this))
    
    _log.notice("eo connecting\n"+
                "to host: "+_opts.host+"\n"+
                "on port: "+_opts.port)
    
    _socket.connect("tcp://"+_opts.host+":"+_opts.port)
    
    if _opts.get then send_get() else
      send_send(_opts.recipient, _opts.message)
    end
  
  fun send_get() =>
    _socket.send(recover zmq.Message
      .push("get")
    end)
  
  fun send_send(recipient: String, message: String) =>
    _socket.send(recover zmq.Message
      .push("send")
      .push(recipient)
      .push(message)
    end)
  
  be received(s: zmq.Socket, p: zmq.SocketPeer, m: zmq.Message) =>
    let iter = m.values()
    try
      match iter.next()
      | "got"  => received_got(p, iter.next(), iter.next())
      | "none" => received_none(p)
      | "sent" => received_sent(p)
      else error
      end
    else
      _log.warn("received unknown protocol message: "+m.string())
    end
    
    exit()
  
  fun received_got(p: zmq.SocketPeer, sender: String, message: String) =>
    _log.notice("got message")
    _log.outv(recover [sender, message] end)
  
  fun received_none(p: zmq.SocketPeer) =>
    _log.notice("no message to get")
  
  fun received_sent(p: zmq.SocketPeer) =>
    _log.notice("sent message")
  
  fun ref exit() =>
    _socket.dispose()
