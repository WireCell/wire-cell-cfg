# Wire Cell Config

This repository holds support files for configuring Wire Cell toolkit
and the main `wire-cell` application.

## Jsonnet

The [Jsonnet](http://jsonnet.org/) data language is an extension to
JSON which can be compiled to plain JSON.  It is used here to write
structured and concise configuration information that can be expanded
into a full `wire-cell` configuration file.

Its use is optional for `wire-cell`.  The user is free to use/develop
other JSON generators or write full JSON files by hand.  Likewise the
Jsonnet support provided here is not required to use Jsonnet for your
configuration.

## What is here

This package provides the `wirecell.jsonnet` file which includes a
number of supportive data structures for writing configuration files
in Jsonnet.  In general, it is expected that someone writing a
configuration will understand `wirecell.jsonnet` by reading it
directly.  A few highlights are described in the following sections
and this package provides a number of working examples in the `test/`
directory.

### System of units

Wire Cell provides an internal system of units.  Any external numeric
quantity given to Wire Cell Toolkit is assumed to be in this system.
To assist in specifying such quantities in Jsonnet, a number of unit
symbols are defined.

```JSON
local wc = import "wirecell.jsonnet";
[
    {
	type:"TrackDepos",
	data: {
	    step_size: 1.0 * wc.millimeter,
		//...
		}
    }
]
```

### Functions

A number of functions are defined to assist in representing common data types.  For example `point()` and `ray()`

```JSON
{
  // ...
  ray : wc.ray(wc.point(10,0,0,wc.cm), wc.point(100,10,10,wc.cm))
},
```

### Default Structures

Some common structures are defined with default objects so that they
may be extended/overridden.  For example, the `Node` object defines a
default `type`, `name` and `port` to be used in a graph connection.
It is typical to override at least the `type`:

```JSON
graph:[
{
  tail: wc.Node {type:"TrackDepos"},
  head: wc.Node {type:"DumpDepos"}
},
//...
]
```



## Tests

Running the configuration tests is done through the files under
`test/`.  They rely on a simple ad-hoc test harness.  All tests can be
run from the top-level `wire-cell` source directory after a build
like:

```bash
./cfg/test/test_all.sh
```

A single test can be run like:

```bash
./cfg/test/test_one.sh <testname>
```

Each test has a `test_<testname>.jsonnet` file.

```bash
ls cfg/test/test_*.jsonnet
```

These main JSonnet files are typically composed of some chunks reused
by the various different tests.  The chunks are named like
`cfg_*.jsonnet`.  The body of each main `test_<testname>.jsonnet`
largely consists of the data flow graph definition for the `TbbFlow`
Wire Cell application object.


