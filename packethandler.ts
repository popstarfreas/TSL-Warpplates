import PacketReader from "dimensions/packets/packetreader";
import PacketTypes from "dimensions/packettypes";
import Client from "../../client";
import GenericPacketHandler from "../../handlers/genericpackethandler";
import Packet from "../../packet";
import Warpplates from "./";

class PacketHandler implements GenericPacketHandler {
    private _warpplates: Warpplates;

    constructor(warpplates: Warpplates) {
        this._warpplates = warpplates;
    }

    public handlePacket(client: Client, packet: Packet): boolean {
        let handled = false;
        switch (packet.packetType) {
            case PacketTypes.UpdatePlayer:
                handled = this.handleUpdatePlayer(client, packet);
                break;
        }

        return handled;
    }

    private handleUpdatePlayer(client: Client, packet: Packet): boolean {
        const reader = new PacketReader(packet.data);
        reader.readByte();
        reader.readByte();
        reader.readByte();
        reader.readByte();
        const x = Math.round(reader.readSingle() / 16);
        const y = Math.round(reader.readSingle() / 16);
        const boundary = 3;

        for (const warpplate of this._warpplates.warpplates) {
            if (Math.abs(warpplate.x - x) <= boundary && Math.abs(warpplate.y - y) <= boundary) {
                this._warpplates.sendClientTo(warpplate.dimension, client);
            }
        }

        return false;
    }
}

export default PacketHandler;
