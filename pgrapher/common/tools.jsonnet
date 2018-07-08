
// This file provides a function which takes a params object (see
// ../params/) and returns a data structure with a number of
// sub-objects that may configure various WCT "tool" type componets
// which are not INodes.

local wc = import "wirecell.jsonnet";

function(params)
{
    random : {
        type: "Random",
        data: {
            generator: "default",
            seeds: [0,1,2,3,4],
        }
    },

    // One FR per field file.
    fields : std.mapWithIndex(function (n, fname) {
        type: "FieldResponse",
        name: "field%d"%n,
        data: { filename: fname }
    }, params.files.fields),

    field: $.fields[0],         // the nominal field

    perchanresp : {
        type: "PerChannelResponse",
        data: {
            filename: params.files.chresp,
        }
    },

    wires : {
        type: "WireSchemaFile",
        data: { filename: params.files.wires }
    },

    elec_resp : {
        type: "ElecResponse",
        data: {
            shaping: params.elec.shaping,
            gain: params.elec.gain,
            postgain: params.elec.postgain,
            nticks: params.daq.nticks,
            tick: params.daq.tick,
        },
    },

    rc_resp : {
        type: "RCResponse",
        data: {
            width: 1.0*wc.ms,
            tick: params.daq.tick,
            nticks: params.daq.nticks,
        }
    },

    // there is one trio of PIRs (one per wire plane in a face) for
    // each field response.
    pirs : std.mapWithIndex(function (n, fr) [
        {
            type: "PlaneImpactResponse",
            name : "PIR%splane%d" % [fr.name, plane],
            data : {
                plane: plane,
                tick: params.daq.tick,
                nticks: params.daq.nticks,
                field_response: wc.tn(fr),
                // note twice we give rc so we have rc^2 in the final convolution
                other_responses: [wc.tn($.elec_resp), wc.tn($.rc_resp), wc.tn($.rc_resp)],
            },
            uses: [fr, $.elec_resp, $.rc_resp],
        } for plane in [0,1,2]], $.fields),

    // One anode per detector "volume"
    anodes : [{
        type : "AnodePlane",
        name : vol.name,
        data : {
            // This ID is used to pick out which wires in the
            // WireSchema belong to this anode plane.
            ident : vol.wires,
            nimpacts: params.sim.nimpacts,
            // The wire schema file
            wire_schema: wc.tn($.wires),

            faces : vol.faces,
        },
        uses: [$.wires],
    } for vol in params.det.volumes],

}
