local params = import "params.jsonnet";
local tools_maker = import "../common/tools.jsonnet";
local tools = tools_maker(params);
local chndb_maker = import "chndb.jsonnet";
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

    
    
