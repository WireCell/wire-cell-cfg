/*
  This holds global 
*/

local wc = import "wirecell.jsonnet";
{
    drift_speed: 1.114*wc.mm/wc.us,
    gain: 14.0,
    shaping: 2*wc.us,
    readout: 5.0*wc.ms,
    tick: 0.5*wc.us,  
}
