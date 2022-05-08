var TC = "gcc"
#var TC = "clang"
#var TC = "tcc"

proc commonOpt() =
    switch "passC","-ffunction-sections"
    switch "passC","-fdata-sections"
    switch "passC","-Wl,--gc-sections"

switch "d","danger"
switch "d","ssl"

switch "passL","-s"
switch "opt","size"

const NIMCACHE = ".nimcache_" & TC
switch "nimcache",NIMCACHE


case TC
    of "gcc":
        commonOpt()
        when true : # These options let linking time slow instead of reducing code size.
            switch "passC","-flto"
            switch "passL","-flto"
    of "clang":
        commonOpt()


switch "cc" ,TC
echo "Compiler: ",TC
