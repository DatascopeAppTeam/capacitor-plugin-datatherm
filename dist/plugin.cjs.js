'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var core = require('@capacitor/core');

const DataTherm = core.registerPlugin('DataTherm', {
    web: () => Promise.resolve().then(function () { return web; }).then(m => new m.DataThermWeb()),
});

class DataThermWeb extends core.WebPlugin {
    async getImage() {
        return { data: { "cancelled": true } };
    }
}

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    DataThermWeb: DataThermWeb
});

exports.DataTherm = DataTherm;
//# sourceMappingURL=plugin.cjs.js.map
