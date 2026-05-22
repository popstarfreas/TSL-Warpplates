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
          err->JsExn.message->Option.getOr("(Error message not found)"),
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
  switch TerrariaPacket.Packet.DimensionsUpdate.toBuffer(
    SwitchServer(dimension->String.toLowerCase),
  ) {
  | Ok(data) => client->Client.sendPacket(data->Obj.magic)
  | Error(_) => ()
  }
}

let messageTimeKey = "warpplates-login-required"
let packetHandler = TerrariaServerLite.ExtensionPacketHandler.make((
  self: t,
  _extension: Extension.t,
  client: Client.t,
  packet: Packet.t,
) => {
  switch packet.packetType->PacketType.fromInt {
  | Some(PacketType.PlayerUpdate) => {
      let playerUpdate = TerrariaPacket.Packet.PlayerUpdate.parse(packet.data->Obj.magic)
      let position = switch playerUpdate {
      | Ok({position}) => Some(position)
      | Error(_) => None
      }
      let (positionX, positionY) = switch position {
      | Some(position) => (
          (position.x /. 16.0)->Float.toInt,
          (position.y /. 16.0)->Float.toInt,
        )
      | None => (-9999, -9999)
      }
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
