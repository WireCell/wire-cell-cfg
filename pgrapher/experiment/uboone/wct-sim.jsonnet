local cli = import "pgrapher/ui/cli/nodes.jsonnet";

local params = import "pgrapher/experiment/uboone/params.jsonnet";
local tools_maker = import "pgrapher/common/tools.jsonnet";

local tools = tools_maker(params);


local sim_maker = import "pgrapher/experiment/uboone/sim.jsonnet";
local sim = sim_maker(params, tools)
