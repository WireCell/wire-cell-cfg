(import "test_drifter.jsonnet") + [
    {
	type: "wire-cell",
	data: {
	    plugins: ["WireCellGen","WireCellApps"]
	}
    },
    {
	type: "Drifter"
    },
    
    {
	type: "ConfigDumper",
	data: { components: ["Drifter","TrackDepos"] }
    }
]

