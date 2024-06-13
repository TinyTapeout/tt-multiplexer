#
# Updates final GDS/LEF
#

# Load cell
set project [lindex $argv $argc-1]
load $project

# Flatten
set bbox [property FIXED_BBOX]
set psdm [property MASKHINTS_PSDM]
set nsdm [property MASKHINTS_NSDM]

select top cell
flatten flat_tmp
load flat_tmp
cellname delete $project
cellname rename flat_tmp $project

property FIXED_BBOX $bbox
property MASKHINTS_PSDM "[property MASKHINTS_PSDM] $psdm"
property MASKHINTS_NSDM "[property MASKHINTS_NSDM] $nsdm"

# GDS
gds write ../gds/$project.gds

# LEF
lef write ../lef/$project.lef -pinonly -hide

# Done
quit -noprompt
