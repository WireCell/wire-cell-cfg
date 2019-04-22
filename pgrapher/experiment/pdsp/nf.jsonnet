// This provides some noise filtering related pnodes,

local g = import 'pgraph.jsonnet';
local wc = import 'wirecell.jsonnet';
local gainmap = import 'pgrapher/experiment/pdsp/chndb-rel-gain.jsonnet';

function(params, anode, chndbobj, n, name='')
  {

//    local bitshift = {
//        type: "mbADCBitShift",
//        name:name,
//        data: {
//            Number_of_ADC_bits: params.adc.resolution,
//            Exam_number_of_ticks_test: 500,
//            Threshold_sigma_test: 7.5,
//            Threshold_fix: 0.8,
//        },
//    },
//    local status = {
//      type: 'mbOneChannelStatus',
//      name: name,
//      data: {
//        Threshold: 3.5,
//        Window: 5,
//        Nbins: 250,
//        Cut: 14,
//        anode: wc.tn(anode),
//      },
//    },
    local single = {
      type: 'pdOneChannelNoise',
      name: name,
      data: {
        noisedb: wc.tn(chndbobj),
        anode: wc.tn(anode),
      },
    },
    local grouped = {
      type: 'mbCoherentNoiseSub',
      name: name,
      data: {
        noisedb: wc.tn(chndbobj),
        anode: wc.tn(anode),
      },
    },
    local sticky = {
      type: 'pdStickyCodeMitig',
      name: name,
      data: {
        extra_stky: [
          {channel:   4, bits: [6]  },
          {channel: 159, bits: [6]  },
          {channel: 164, bits: [36] },
          {channel: 168, bits: [7]  },
          {channel: 323, bits: [24] },
          {channel: 451, bits: [25] },
        ],
        noisedb: wc.tn(chndbobj),
        anode: wc.tn(anode),
      },
    },
    local gaincalib = {
      type: 'pdRelGainCalib',
      name: name,
      data: {
        noisedb: wc.tn(chndbobj),
        anode: wc.tn(anode),
        rel_gain: gainmap.rel_gain,
      },
    },


    local obnf = g.pnode({
      type: 'OmnibusNoiseFilter',
      name: name,
      data: {

        // This is the number of bins in various filters
        nsamples: params.nf.nsamples,

        //maskmap: { chirp: "bad", noisy: "bad" },
        maskmap: {sticky: "bad", ledge: "bad", noisy: "bad"},
        channel_filters: [
          //wc.tn(bitshift),
          wc.tn(sticky),
          wc.tn(single),
          wc.tn(gaincalib),
        ],
        grouped_filters: [
          wc.tn(grouped),
        ],
        channel_status_filters: [
          //wc.tn(status),
        ],
        noisedb: wc.tn(chndbobj),
        intraces: 'orig%d' % n,  // frame tag get all traces
        outtraces: 'raw%d' % n,
      },
      //}, uses=[chndbobj, anode, single, grouped, bitshift, status], nin=1, nout=1),
      //}, uses=[chndbobj, anode, single, grouped, status], nin=1, nout=1),
    }, uses=[chndbobj, anode, sticky, single, grouped, gaincalib], nin=1, nout=1),


//    local pmtfilter = g.pnode({
//        type: "OmnibusPMTNoiseFilter",
//        name:name,
//        data: {
//            intraces: "quiet",
//            outtraces: "raw",
//            anode: wc.tn(anode),
//        }
//    }, nin=1, nout=1, uses=[anode]),

    //pipe:  g.pipeline([obnf, pmtfilter], name=name),
    pipe: g.pipeline([obnf], name=name),
  }.pipe
