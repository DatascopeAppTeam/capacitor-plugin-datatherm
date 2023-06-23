import { WebPlugin } from '@capacitor/core';

import type { DataThermPlugin } from './definitions';

export class DataThermWeb extends WebPlugin implements DataThermPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
