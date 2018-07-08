// normally don't do sibling imports, but this is for testing.
local params = import "../params/base.jsonnet";
local drifter_maker = import "drifter.jsonnet";
local drifter = drifter_maker(params.lar, params.det.volumes);
drifter
