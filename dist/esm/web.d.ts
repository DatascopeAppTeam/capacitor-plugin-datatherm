import { PluginResultData, WebPlugin } from '@capacitor/core';
import type { DataThermPlugin } from './definitions';
export declare class DataThermWeb extends WebPlugin implements DataThermPlugin {
    getImage(): Promise<PluginResultData>;
}
