import { registerPlugin } from '@capacitor/core';

import type { DataThermPlugin } from './definitions';

const DataTherm = registerPlugin<DataThermPlugin>('DataTherm', {
  web: () => import('./web').then(m => new m.DataThermWeb()),
});

export * from './definitions';
export { DataTherm };
