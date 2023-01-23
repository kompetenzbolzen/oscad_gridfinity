# oscad-gridfinity

[GridFinity](https://gridfinity.xyz/) implementation for [OpenSCAD](https://openscad.org/)

![Bottom View](img/bottom.png)

Create fully parameterized Templates for GridFinity.

`gridfinity(<x>, <y>, <z>, lip=<>, magnets=<>);`

* **x, y** Vertical size in *GridFinity* units
* **z** Height in GridFinity units (`z * 7mm`). This is excluding the base and stacking lip.
* **lip** `true/false` Sets wether to put a stacking lip on top. Only works with z >= 1. Default `true`
* **magnets** `true/false` Sets wether to put holes for magnets in the base. Default `false`
* **fill** `true/false` Sets wether the created object is solid or hollow. Default `true`
* **bottom_height** Height offset for floor. Only applicable, if `fill == false`. Default `0`

## Example

```scad
use <gridfinity.scad>

gridfinity(2, 1, 2, lip=true, magnets=false);
```

## Building

STLs and PNGs can be built with GNU make by just running
`make stl` and `make png`
respectively.

T build a single object, use the desired file as a target:
`make example.stl`

## License

Licensed under the MIT License. Consult `LICENSE`.
