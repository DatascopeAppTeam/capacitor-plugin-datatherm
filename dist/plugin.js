var capacitorDataTherm = (function (exports, core) {
    'use strict';

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

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
