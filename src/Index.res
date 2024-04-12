open TerrariaServerLite

let loadCommands = (
  _warpplates: Warpplates.t,
  parent,
  handlers: Extension.commandHandlers<Warpplates.t>,
) => {
  [ExtensionCommand.construct(WarpplateCommand.command, parent, handlers)]
}

let constructor = (extension: Extension.t, _server: Server.t): Warpplates.t => {
  let warpplates = Warpplates.make(extension)
  warpplates->Warpplates.loadWarpplates

  warpplates
}

// Required to be called default as it turns into export.default
let default: Extension.clsOfT<Warpplates.t> = Extension.make(
  ~constructor,
  ~loadCommands,
  ~packetHandler=Warpplates.packetHandler,
  ~name="Warpplates",
  ~version="v2.0.0",
  ~order=0,
  (),
)
