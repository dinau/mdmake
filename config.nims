const TC = "gcc"
#const TC = "clang"
#const TC = "tcc"
#
switch "d","danger"
switch "d","ssl"

switch "passL","-s"
switch "opt","size"

const NIMCACHE = ".nimcache_" & TC
switch "nimcache",NIMCACHE

switch "cc" ,TC
case TC
    of "gcc","clang":
        switch "passC","-ffunction-sections"
        switch "passC","-fdata-sections"
        switch "passC","-Wl,--gc-sections"
        if TC == "gcc":
            switch "passC","-flto"
            switch "passL","-flto"

