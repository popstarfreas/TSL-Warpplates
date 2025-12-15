open TerrariaServerLite

let handleAddWarpplate = (warpplates: Warpplates.t, client: Client.t, params: array<string>) => {
  let dimension = params->Array.filter(param => param !== "-noguests")->Array.join(" ")
  let position = client->Client.player->Player.position
  let x = Math.round(position.x /. 16.)->Float.toInt
  let y = Math.round(position.y /. 16.)->Float.toInt
  let noGuests = params->Array.some(param => param === "-noguests")
  warpplates->Warpplates.addWarpplate({dimension, x, y, noGuests})
  client->Client.sendChatMessage(
    ~message=`Added warpplate to ${dimension} at ${x->Belt.Int.toString}, ${y->Belt.Int.toString}`,
    (),
  )
  ()
}

let handleIgnoreWarpplates = (client: Client.t) => {
  client->Client.sendChatMessage(
    ~message="This is not yet implemented.",
    ~color={\"R": 255, \"G": 0, \"B": 0},
    (),
  )
}

let command = ExtensionCommand.make(["warpplate"], "warpplate.set", (
  warpplates: Warpplates.t,
  _extension,
  command,
  client: Client.t,
) => {
  switch command.parameters->Belt.List.fromArray {
  | list{"add", ...params} => handleAddWarpplate(warpplates, client, params->Belt.List.toArray)
  | list{"ignore", ..._} => handleIgnoreWarpplates(client)
  | _ => client->Client.sendChatMessage(~message="Unknown parameter.", ())
  }
})
