import { PluginResultData } from "@capacitor/core";
export interface DataThermPlugin {
    getImage(): Promise<PluginResultData>;
}
export interface DataThermPluginData {
    Celicius: number;
    Image: string;
}
