local wc = import "wirecell.jsonnet";
[
    {
	type:"TrackDepos",
	data: {
	    step_size: 1.0 * wc.millimeter,
	    tracks: [
		{
		    time: 10.0*wc.ns,
		    charge: -1,
		    ray : wc.ray(wc.point(10,0,0,wc.mm), wc.point(100,10,10,wc.mm))
		},
		{
		    time: 120.0*wc.ns,
		    charge: -2,
		    ray : wc.ray(wc.point(1,0,0,wc.mm), wc.point(2, -100,0,wc.mm))
		},
		{
		    time: 99.0*wc.ns,
		    charge: -3,
		    ray : wc.ray(wc.point(130,50,50,wc.mm), wc.point(11,-50,-30,wc.mm))
		}
	    ],
	}
    }
]


