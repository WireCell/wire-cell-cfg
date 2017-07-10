local anodes = import "multi/anodes.jsonnet";
{

    fieldresponse : {
        type: "FieldResponse",
        data: {
            filename: anodes.nominal.data.fields,
        }
    },

    perchanresp : {
        type : "PerChannelResponse",
        data : {
            filename: "calib_resp_v1.json.bz2",
        },
    },
    

}
