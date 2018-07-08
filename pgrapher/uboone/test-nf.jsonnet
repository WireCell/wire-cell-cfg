local params = import "params.jsonnet";
local tools_maker = import "../common/tools.jsonnet";
local nf_maker = import "nf.jsonnet";
local chndb_maker = import "chndb.jsonnet";

local tools = tools_maker(params);
local anode = tools.anodes[0];

local chndbs = chndb_maker(params, tools.anodes[0], tools.field);
local nf = nf_maker(params, anode, chndbs.wct("before"));

nf
