#!/bin/bash
python export.py export --export_extension=stl $PWD/Gears/GearCreator.scad $PWD/Gears/GearCreator.json $PWD/exports/stl
python export.py export --export_extension=csg $PWD/Gears/GearCreator.scad $PWD/Gears/GearCreator.json $PWD/exports/csg
python export.py export --export_extension=stl $PWD/Bearings/Bearings.scad $PWD/Bearings/Bearings.json $PWD/exports/stl
python export.py export --export_extension=csg $PWD/Bearings/Bearings.scad $PWD/Bearings/Bearings.json $PWD/exports/csg
