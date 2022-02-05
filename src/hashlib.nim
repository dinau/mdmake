import os
import std/hashes
import strutils

const HASH_DIR = "hash"

# --- Forward definition
#
proc getHashDir() : string
proc getContentHash(fname:string): int
proc getSavedHash(fname:string): int
proc getHashFileName(fname:string) : string

# --- Global function
#
proc saveHash*(mdfName:string): int =
    let hashDir = getHashDir()
    if not dirExists(hashDir): os.createDir(hashDir)
    let hashFileNameAbs = getHashFileName(mdfName)

    result = getContentHash(mdfName)
    writeFile(hashFileNameAbs,$result)

# 拡張子を".has"に変えてそのファイルがhash/*.hasとして存在するか確認
proc havehashFile*(fname:string):bool =
    let res = getHashFileName(fname)
    return fileExists res

proc isEqualHash*(fname:string):bool =
    let curHash = getContentHash(fname)
    let prevHash = getSavedHash(fname)

    result =  (curHash == prevHash)


# --- Local function
#
proc getHashFileName(fname:string) : string =
    var sTmp = changeFileExt(fname, "") # 拡張子をカット
    sTmp = os.absolutePath(sTmp)        # 絶対パス化
    let sHashId =  $(hash(sTmp)).uint   # 拡張子を除いた絶対パスをハッシュ化でIDとする
    #
    let paths = fname.splitFile()
    result = os.joinPath(getHashDir(), paths.name & "-" & sHashId ) & ".has"
    #echo "ハッシュファイル名: ",result
    #let hashFileName = changeFileExt(mdPath.name, ".has")

proc getHashDir() : string =
    let paths = os.getAppFilename().splitFile()
    joinPath(paths.dir , HASH_DIR)

# Hashファイルが無いときは作る(その時の戻り値は0を返す)
proc getSavedHash(fname:string): int =
    let hashFileNameAbs = getHashFileName(fname)
    if not fileExists(hashFileNameAbs):
        discard saveHash(fname)
        result = 0
    else:
        result = parseInt readFile(hashFileNameAbs)

proc getContentHash(fname:string): int =
    result = hash(readFile(fname)).int

when isMainModule:
    let fname = "test.md"
    echo "fname : ",fname
    echo "getSavedHash(fname): ",$getSavedHash(fname)
    echo "getContentHash(fname): ",$getContentHash(fname)
    echo "isEqualHash(fname): ",isEqualHash(fname).repr

