local wc = import "wirecell.jsonnet";
local pnode = import "pnode.jsonnet";
local sim = import "sim.jsonnet";

pnode.strip_pnodes(wc.resolve_uses([sim.multi_noisy]))
