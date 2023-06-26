import { PluginResultData, WebPlugin } from '@capacitor/core';

import type { DataThermPlugin } from './definitions';

export class DataThermWeb extends WebPlugin implements DataThermPlugin {
  async getImage(): Promise<PluginResultData> {
    return {data: {"cancelled" : true}};
  }
}
