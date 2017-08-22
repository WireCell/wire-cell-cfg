// This file pulls together various bits of lower level configuration
// in a form to use in a main sequence configuration file.

local wc = import "wirecell.jsonnet";

local gen = import "general.jsonnet";
local nf = import "nf.jsonnet";
local sp = import "sp.jsonnet";

{
    
    sequence: gen.sequency + nf.sequence + sp.sequence,


    // The Omnibus is the main class that handles frames.
    omnibus : {
	
    }

}
