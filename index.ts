import * as bcrypt from "bcrypt";
import PacketWriter from "dimensions/packets/packetwriter";
import PacketTypes from "dimensions/packettypes";
import * as fs from "fs";
import * as Winston from "winston";
import ChatMessage from "../../chatmessage";
import Client from "../../client";
import Database from "../../database";
import TerrariaServer from "../../terrariaserver";
import Extension from "../extension";
import PacketHandler from "./packethandler";

interface Warpplate {
    dimension: string;
    x: number;
    y: number;
}

class Warpplates extends Extension {
    public name = "Warpplates";
    public version = "v1.0";
    public path = "";
    private _warpplates: Warpplate[] = [];

    constructor(server: TerrariaServer) {
        super(server);
        this.packetHandler = new PacketHandler(this);
        this.loadWarpplates();
        this.loadCommands(__dirname);
    }

    public get warpplates(): Warpplate[] {
        return Object.assign(this._warpplates);
    }

    public addWarpplate(warpplate: Warpplate): void {
        this._warpplates.push(warpplate);
        this.saveWarpplates();
    }

    public sendClientTo(dimension: string, client: Client): void {
        const packet = new PacketWriter()
            .setType(PacketTypes.DimensionsUpdate)
            .packInt16(2)
            .packString(dimension.toLowerCase())
            .data;

        client.sendPacket(packet);
    }

    private async warpplatesFileExists(): Promise<boolean> {
        return new Promise<boolean>((resolve, reject) => {
            fs.exists("../persistence/warpplates.json", (exists) => {
                resolve(exists);
            });
        });
    }

    private async loadWarpplates(): Promise<void> {
        if (await this.warpplatesFileExists()) {
            this.loadWarpplatesFromFile();
        }
    }

    private async loadWarpplatesFromFile(): Promise<void> {
        const fileContents = await this.readWarpplatesFile();
        try {
            this._warpplates = JSON.parse(fileContents);
        } catch (e) {
            console.log("Warpplates could not be loaded from file.");
        }
    }

    private readWarpplatesFile(): Promise<string> {
        return new Promise<string>((resolve, reject) => {
            fs.readFile("../persistence/warpplates.json", (err, data) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(data.toString());
                }
            });
        });
    }

    private saveWarpplates(): Promise<void> {
        return new Promise<void>((resolve, reject) => {
            fs.writeFile("../persistence/warpplates.json", JSON.stringify(this._warpplates), (err) => {
                if (err) {
                    reject(err);
                } else {
                    resolve();
                }
            });
        });
    }
}

export default Warpplates;
