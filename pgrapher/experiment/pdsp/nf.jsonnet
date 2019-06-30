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
        resmp: [
          {channels: std.range(2128, 2175), sample_from: 5996},
          {channels: std.range(1520, 1559), sample_from: 5996},
          {channels: std.range( 440,  479), sample_from: 5996},
        ],
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
          {channels: std.range(n * 2560, (n + 1) * 2560 - 1), bits: [0,1,63]},
          {channels: [4], bits: [6]  },
          {channels: [159], bits: [6]  },
          {channels: [164], bits: [36] },
          {channels: [168], bits: [7]  },
          {channels: [323], bits: [24] },
          {channels: [451], bits: [25] },
        ],
        noisedb: wc.tn(chndbobj),
        anode: wc.tn(anode),
        stky_sig_like_val: 15.0,
        stky_sig_like_rms: 2.0,
        stky_max_len: 5,
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

        // Nonzero forces the number of ticks in the waveform
        nticks: 0,

        // channel bin ranges are ignored
        // only when the channelmask is merged to `bad`
        maskmap: {sticky: "bad", ledge: "bad", noisy: "bad"},
        channel_filters: [
          wc.tn(sticky),
          wc.tn(single),
          wc.tn(gaincalib),
        ],
        grouped_filters: [
          wc.tn(grouped),
        ],
        channel_status_filters: [
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
