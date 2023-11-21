local ffi = require("ffi")
local reg = debug.getregistry()
local steam = reg.Portal
local api = steam.api

--- The Socket object establishes peer-to-peer connections and sends data between clients.
-- @module socket
-- @alias Socket
-- @inherit Handle
local Socket = {}
setmetatable(Socket, { __index = reg.Handle })
reg.Socket = Socket

local kinds =
{
  unreliable = 0,
  nodelay = 1,
  reliable = 2,
  buffered = 3,
}

--- This is an internal function.
-- Please use @{steam.getSocket} instead.
-- @tparam[opt=0] number channel Channel number
-- @tparam[opt="unreliable"] string kind Kind of socket: "unreliable", "nodelay", "reliable" or "buffered"
-- @treturn Socket Socket object
-- @see steam.getSocket
function Socket:init(ch, kind)
  self.channel = ch or 0
  self.peer = nil
  self.kind = kinds[kind or "unreliable"]
end

--- Destroys the socket closing any open connections.
-- All subsequent calls to this object will fail.
function Socket:destroy()
  self:setPeer()
  self.channel = nil
  self.peer = nil
  self.kind = nil
end

--- Returns the channel number of the socket.
-- @treturn number Channel number
function Socket:getId()
  return self.channel
end

--- Sets the P2P protocol for the socket.
-- "unreliable" is basic UDP where packets can be lost, or in rare cases arrive out of order.
-- In case of connection problems, packet are batched until the connection is re-opened again.
-- "nodelay" is the same as the previous, but if the underlying P2P connection isn't yet established the packet will be thrown away.
-- "reliable" ensures that that the packets will always arrive in order. This is slower and allows sending larger messages efficiently. 
-- "buffered" is the same as the previous, but messages will accumulate and be send together in one packet.
-- This is slower but allows you to send a set of smaller messages reliably.
-- @tparam string protocol Protocol kind: "unreliable", "nodelay", "reliable" or "buffered"
function Socket:setProtocol(kind)
  self.kind = kinds[kind]
  assert(self.kind)
end

--- Sets the peer associated this Socket object.
-- Both sides have to set each other as peers in order to establish a real P2P connection.
-- @tparam User peer User that we want to connect with
-- @see Socket:getPeer
function Socket:setPeer(peer)
  if peer == nil or peer ~= self.peer then
    if self.peer then
      api.Networking.CloseP2PChannelWithUser(self.peer.handle, self.channel)
      -- todo: check if all channels to this peer are closed
      -- api.Networking.CloseP2PSessionWithUser(self.peer)
      self.peer = nil
    end
    if peer then
      self.peer = peer
      api.Networking.AcceptP2PSessionWithUser(peer.handle)
    end
  end
end

--- Gets the peer associated this Socket object.
-- @treturn User Peer
-- @see Socket:setPeer
function Socket:getPeer()
  return self.peer
end

--- Sends data to the peer.
-- @tparam string data Outgoing message
-- @tparam[opt] User user Receiver, if different from the peer
-- @treturn boolean True if the message was sent
-- @see Socket:receive
function Socket:send(data, user)
  user = user or self.peer
  return api.Networking.SendP2PPacket(user.handle, data, #data, self.kind, self.channel)
end

local buffer = ffi.new("unsigned char[1024]")
local size = ffi.new("int[1]")
local sender = ffi.new("CSteamID[1]")
--- Receives data from the peer if available.
-- This call is not blocking and will return nil if no data is available.
-- @treturn string Incoming message
-- @treturn User Sender, usually the same as the peer
-- @see Socket:send
function Socket:receive()
  if api.Networking.IsP2PPacketAvailable(size, self.channel) then
    local packet = buffer
    local n = size[0]
    if n > 1024 then
      -- only allocate if this packet exceeds the buffer size
      packet = ffi.new("char[?]", n)
    end
    if api.Networking.ReadP2PPacket(packet, n, size, sender, self.channel) then
      if not self.peer or self.peer.handle == sender[0].m_steamid.m_unAll64Bits then
        packet = (packet == ffi.NULL) and "" or ffi.string(packet, n)
        return packet, steam.getUser(sender[0].m_steamid.m_unAll64Bits)
      end
    end
  end
end

local state = ffi.new("P2PSessionState_t")
--- Finds the remote address of the peer.
-- This is used for debugging purposes.
-- @tparam[opt] User peer User, if different from the peer
-- @treturn string IP address of the peer (in IPv4 format)
-- @treturn number Port number
-- @treturn boolean True if using a Steam relay server
function Socket:getAddress(user)
  user = user or self.peer
  if api.Networking.GetP2PSessionState(user.handle, state) then
    -- todo: does not support ipv6
    local c = state.m_nRemoteIP.byte
    local ip = string.format("%d.%d.%d.%d", c[3], c[2], c[1], c[0])
    return ip, state.m_nRemotePort, state.m_bUsingRelay > 0
  end
end

--- Checks if there is an active and open connection with the peer.
-- @tparam[opt] User peer User, if different from the peer
-- @treturn boolean True if connected
function Socket:isConnected(user)
  user = user or self.peer
  if api.Networking.GetP2PSessionState(user.handle, state) then
    return state.m_bConnectionActive > 0
  end
end