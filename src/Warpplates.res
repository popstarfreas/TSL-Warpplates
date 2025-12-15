module Client = TerrariaServerLite.Client
module Extension = TerrariaServerLite.Extension
module Log = TerrariaServerLite.Log
module Server = TerrariaServerLite.Server
module PacketType = TerrariaServerLite.PacketType
module Packet = TerrariaServerLite.Packet
module ExtMap = TerrariaServerLite.ExtMap

type warpplate = {
  dimension: string,
  x: int,
  y: int,
  noGuests: bool,
}

type t = {
  mutable warpplates: array<warpplate>,
  logger: Log.boundT,
}

let make = (extension: Extension.t): t => {
  {
    warpplates: [],
    logger: Log.forExtension(extension->Extension.server->Server.logger, extension),
  }
}

@module("fs")
external writeFile: (string, string, nullable<JsExn.t> => unit) => unit = "writeFile"
let saveWarpplates = (self: t) => {
  let json = JSON.stringifyAny(self.warpplates)
  switch json {
  | Some(warpplates) =>
    writeFile("./persistence/warpplates.json", warpplates, err => {
      switch err->Nullable.toOption {
      | Some(err) =>
        self.logger->Log.error(
          "Could not write warpplates to file. " ++
          err->JsExn.message->Belt.Option.getWithDefault("(Error message not found)"),
        )
      | None => ()
      }
    })
  | None => self.logger->Log.error("Could not convert warpplates to json.")
  }
}

@module("fs")
external readFile: (string, (nullable<JsExn.t>, nullable<NodeJs.Buffer.t>) => unit) => unit =
  "readFile"
let loadWarpplates = (self: t) => {
  readFile("./persistence/warpplates.json", (err, data) => {
    switch (err->Nullable.toOption, data->Nullable.toOption) {
    | (None, Some(data)) =>
      self.warpplates = data->NodeJs.Buffer.toString->JSON.parseOrThrow->Obj.magic
    | _ => ()
    }
  })
}

let addWarpplate = (self: t, warpplate: warpplate) => {
  self.warpplates->Array.push(warpplate)->ignore
  saveWarpplates(self)
}

let sendClientToDimension = (client: Client.t, dimension: string) => {
  open TerrariaServerLite.PacketWriter
  client->Client.sendPacket(
    TerrariaServerLite.PacketWriter.make()
    ->setType(PacketType.DimensionsUpdate)
    ->packInt16(2)
    ->packString(dimension->String.toLowerCase)
    ->data,
  )
}

let messageTimeKey = "warpplates-login-required"
let packetHandler = TerrariaServerLite.ExtensionPacketHandler.make((
  self: t,
  _extension: Extension.t,
  client: Client.t,
  packet: Packet.t,
) => {
  open TerrariaServerLite.PacketReader
  switch packet.packetType->PacketType.fromInt {
  | Some(PacketType.PlayerUpdate) => {
      let reader = TerrariaServerLite.PacketReader.make(packet.data)
      let _playerId = reader->readByte
      let _control = reader->readByte
      let _pulley = reader->readByte
      let _misc = reader->readByte
      let _sleepingInfo = reader->readByte
      let _selectedItem = reader->readByte
      let positionX = (reader->readSingle /. 16.0)->Belt.Float.toInt
      let positionY = (reader->readSingle /. 16.0)->Belt.Float.toInt
      let boundary = 3
      let matchedWarpplate = self.warpplates->Array.find(({x, y}) => {
        Math.Int.abs(x - positionX) <= boundary && Math.Int.abs(y - positionY) <= boundary
      })

      switch matchedWarpplate {
      | Some({dimension, noGuests}) => {
          switch (client->Client.getUserAccount, noGuests) {
          | (Some(_), true)
          | (_, false) =>
            sendClientToDimension(client, dimension)
          | _ => {
              let lastSentMessage = client->Client.extProperties->ExtMap.get(messageTimeKey)
              switch lastSentMessage {
              | Some(lastSentMessage) => {
                  let lastSentMessage = Obj.magic(lastSentMessage)
                  if Date.now() -. lastSentMessage > 3000.0 {
                    client->Client.sendChatMessage(
                      ~message="You need to be logged-in to use this warpplate.",
                      ~color={
                        \"R": 255,
                        \"G": 0,
                        \"B": 0,
                      },
                      (),
                    )
                    client
                    ->Client.extProperties
                    ->ExtMap.set(messageTimeKey, Obj.magic(Date.now()))
                  }
                }
              | None => {
                  client->Client.extProperties->ExtMap.set(messageTimeKey, Obj.magic(Date.now()))
                  client->Client.sendChatMessage(
                    ~message="You need to be logged-in to use this warpplate.",
                    ~color={
                      \"R": 255,
                      \"G": 0,
                      \"B": 0,
                    },
                    (),
                  )
                }
              }
            }
          }
          ()
        }
      | None => ()
      }

      false
    }
  | _ => false
  }
})
