import { registerPlugin } from '@capacitor/core';
const DataTherm = registerPlugin('DataTherm', {
    web: () => import('./web').then(m => new m.DataThermWeb()),
});
export * from './definitions';
export { DataTherm };
//# sourceMappingURL=index.js.map