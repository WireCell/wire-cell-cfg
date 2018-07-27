local params = import "pgrapher/experiment/uboone/params.jsonnet";
local tools_maker = import "pgrapher/common/tools.jsonnet";
local tools = tools_maker(params);
local chndb_maker = import "pgrapher/experiment/uboone/chndb.jsonnet";
local chndbs = chndb_maker(params, tools.anodes[0], tools.field);

{
    wct: {
        before: chndbs.wct("before"),
        after: chndbs.wct("after"),
    },
    wcls: {
        before: chndbs.wcls("before"),
        after: chndbs.wcls("after"),
    },
    multi: chndbs.wcls_multi,
}
