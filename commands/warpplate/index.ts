import Warpplates from "../../";
import Client from "../../../../client";
import Command from "../../../../command";
import CommandHandler from "../../../../commandhandler";
import CommandHandlers from "../../../../commandhandlers";

class WarpplateCommand extends CommandHandler {
    public name = "warpplate";
    public permission = "warpplate.set";
    private _warpplates: Warpplates;

    constructor(warpplates: Warpplates, commandHandlers: CommandHandlers) {
        super(commandHandlers);
        this._warpplates = warpplates;
    }

    public handle(command: Command, client: Client): void {
        switch (command.parameters[0]) {
            case "add":
                this.handleAddWarpplate({
                    name: "warp add",
                    parameters: command.parameters.slice(1)
                }, client);
                break;
        }
    }

    private handleAddWarpplate(command: Command, client: Client): void {
        const dimension = command.parameters[0];
        const x = Math.round(client.player.position.x / 16);
        const y = Math.round(client.player.position.y / 16);

        this._warpplates.addWarpplate({
            dimension,
            x,
            y
        });

        client.sendChatMessage(`Added new warpplate to ${dimension} at ${x}, ${y}`);
    }
}

export default WarpplateCommand;
