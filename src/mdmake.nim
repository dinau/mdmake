## 入力の*.mdファイルはUTF-8/LF(Unix)が前提
## 最初に見つかった "#"で始まる 行をタイトル文字列とする
# first:2021/12 by audin
# nim-1.6.2

const DEBUG = false

const MD_DIR_LIST_FILENAME = "mdmake.dir"
const MD_TEMP_FILENAME = "00temp.md" # *.exeがあるフォルダに生成される

{.push warning[UnusedImport]: off.}
include std/prelude
#import std/pegs
import std/strscans
#
import md2htmlg, hashlib
import template_mdmake
# $MD_TITLE
# $MD_HTML

let html4header = """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "https://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta https-equiv="Content-Type" content="text/html; charset=utf-8">
"""
let htmlEnd = "</html>"

proc conv2html(mdname: string): bool = # True: HTMLに変換した , False: 未変換(何もしない)
    var
        seqMsg: seq[string]
        gReqDos2unix = false
        sHtml,sCmd:string
        #mc: array[4, string]
        sTitle = "  "
    let
        mdFilename = absolutePath(mdname)
        htmlname = mdFilename.changeFileExt(".html")

    ################
    # mdファイルの変更等のチェック
    ################
    block:
        seqMsg.add ( "[TARGET] = " & mdname )
        if not hashFileExists(htmlName): # Hashがない場合(初回)だけ
            gReqDos2unix = true
            seqMsg.add "Hashがない"
        #
        if os.fileExists(htmlname):
            seqMsg.add  "Htmlあり"
            if isEqualHash(mdFilename):
                seqMsg.add "Hashが同じ"
                return
            else:
                seqMsg.add"Hashが違う"
        else:
            seqMsg.add"Htmlなし"

        seqMsg.add("   現在のファイルのHash値: " & $getContentHash(mdname))
        seqMsg.add("   保存されていたHash値: " & $getSavedHash(mdname))

    ################
    # mdファイルの最初に見つかった #.. 行をhtmlのタイトルとして取得する
    ################
    # '#'が行頭に1個以上あれば良い
    for line in lines(mdFilename):
        #if line.contains(peg"'#'+ ' ' {.+}", mc):
        var (res,trash,title) = scanTuple(line,"#$+ $s$+$.")
        if res:
            sTitle  = title
            trash = ""
            break

    ################
    # include ファイル(*.md)をインクルードする
    ################
    # <!-- include "filename.mdi" --> と記述する
    block:
        var sMd:string
        for line in lines(mdFilename):
            #if line.contains(peg"\s* '<!--'  \s+ 'include' {@} '-->' ", mc):
            let (res,mdiName) = scanTuple(line,"$s<!--$sinclude$s$+-->")
            if res:
                var sIncName =mdiName.strip(chars = {' ','"'})
                let paths = mdFilename.splitFile()
                # 絶対パス化 *.mdファイルと同じフォルダとする
                sIncName = os.joinPath(paths.dir , sIncName)
                if fileExists(sIncName):
                    sMd &= readfile(sIncName) # Includeファイルの中身を結合
            else:
                sMd &= line & '\n'
        writeFile(MD_TEMP_FILENAME,sMd)

    ################
    # 目次を[doctoc]で*.mdファイルに追加
    ################
    # https://qiita.com/yumenomatayume/items/d20384da3d7a2fc49967
    # $ npm install -g doctoc
    if "" != findExe("doctoc"):
        when true:
            # includeを反映した目次を作る
            sCmd = "doctoc --github --notitle " & MD_TEMP_FILENAME
            discard execShellCmd(sCmd)
            # オリジナルの目次をアップデート
            sCmd = "doctoc --github --notitle " & mdFilename
            discard execShellCmd(sCmd)

    ################
    # Github APIでHtmlに変換
    ################
    sHtml = md2htmlg(readFile(MD_TEMP_FILENAME))
    if sHtml == "":
        echo "\n -- [ERROR:Server error !!! ] ---: ", MD_TEMP_FILENAME
        return false
    os.removeFile(MD_TEMP_FILENAME)
    ################
    # html: 一旦ファイルに保存(dos2unixをかけるため)
    ################
    writeFile(htmlName, sHtml)

    ################
    # md,html: 暫定: doctocで改行コードがおかしくなる場合をdos2unixで回避
    ################
    if gReqDos2unix: # Hashがない場合(初回)だけ
        if "" != findExe("dos2unix"):
            sCmd = "dos2unix -k $#" % [htmlName] # *.html
            discard execShellCmd(sCmd)
            sCmd = "dos2unix -k $#" % [mdFilename] # *.md
            discard execShellCmd(sCmd)

    ###################################
    # mdファイルはこれ以降変更されない
    ###################################
    discard saveHash(mdFilename) # mdファイルのHashを作って保存
    seqMsg.add "       Hashを作って保存した"
    seqMsg.add("       現在のファイルのHash値: " & $getContentHash(mdname))
    seqMsg.add("       保存されていたHash値: " & $getSavedHash(mdname))
    # デバッグ用出力
    when DEBUG:
        for str in seqMsg: echo str

    ################
    # html: dos2unix後を再読込
    ################
    sHtml = readFile(htmlName)

    ################
    # htmlファイルをテンプレートと結合
    ################
    sHtml = html4header & TEMPLATE
        .replace("$MD_HTML", sHtml)
        .replace("$MD_TITLE", sTitle) & htmlEnd

    ################
    # シーケンスに変換 (行単位で処理するため)
    ################
    var seqHtml = splitLines(sHtml, keepeol = true)

    ################
    # 生成されたhtmlファイルを加工
    ################
    block:
        # 目次のジャンプ先が"href=#TOC_LABEL1"になっていてジャンプできないので
        # "href=#user-content-TOC_LABEL1"に変更
        var
            sCap:string
            iCap:int
            res:bool
        for i, line in seqHtml:
            #if line.contains(peg"'<h'[1-9]'>'", mc):
            (res,iCap) = scanTuple(line,"$s<h$i>")
            if res:
                iCap = 0
                break
            #elif line.contains(peg("'<li><a href=' '\"' '#' {.+}"), mc):
            (res, sCap) = scanTuple(line,"<li><a href=\"#$+$.")
            if res:
                seqHtml[i] = "<li><a href=\"#" & "user-content-" & sCap
            #if line.contains(peg(" '<a href=' '\"' '#' {.+}"), mc):
            (res,sCap) = scanTuple(line,"<a href=\"#$+$.")
            if res:
                seqHtml[i] = "<a href=\"#" & "user-content-" & sCap
        # 画像ファイルがgithubのキャッシュ参照になってしまうのを修正
        when false:
            for i, line in seqHtml:
                if line.contains(peg("'data-canonical-src=\"' {@} [\"] ' style' .+  "), mc):
                    seqHtml[i] = "<p><img src=\"" & mc[0] & "\"></p>"
        else:
            for i, line in seqHtml:
                #if line.contains(peg("'data-canonical-src=\"' {@} [\"] ' style' .+  "), mc):
                var sCap2:string
                (res, sCap2,sCap) = scanTuple(line,"$+data-canonical-src=\"$+\"$sstyle")
                if res:
                    seqHtml[i] = "<p><img src=\"" & sCap & "\"></p>"

    ###################################
    # html ファイルはこれ以降変更されない
    ###################################

    ################
    # seqを文字列に変換
    ################
    sHtml = ""
    for line in seqHtml:
        sHtml &= line

    ################
    # htmlファイルに保存
    ################
    writeFile(htmlName, sHtml)
    result = true

proc main() =
    var
        mdFileList: seq[string] # *.mdファイルのリストを保持
        mdDirList: seq[string]  # *.mdファイルがあるフォルダのリストを保持
        tDelay = 1000 # [msec] 連続処理するとサーバに蹴られるのでテキトーなウエイトを入れる
    if os.paramCount() > 0:
        # *.mdファイルとディレクトリをコマンドライン引数から取得
        for file in os.commandLineParams():
            if dirExists(file): mdDirList.add file
            #else: echo "Error: フォルダがない [$#]" % [file]
            if fileExists(file): mdFileList.add file
            #else: echo "Error: ファイルがない [$#]" % [file]
    elif fileExists(MD_DIR_LIST_FILENAME):
        # 外部ファイルで指定されたフォルダリストからフォルダ名を取得
        for dirname in lines(MD_DIR_LIST_FILENAME):
            mdDirList.add dirname

    for dirname in mdDirList: #フォルダ名から*.mdファイルを全部取得する
        if dirExists(dirname):
            for file in os.walkFiles(os.joinpath(dirname, "*.md")):
                mdFileList.add file

    var genCount = 0 # 処理したファイル数
    when false:
        if mdFileList.len <= 2: # 2個までは連続処理してみる
            tDelay = 0 # No wait
    for file in mdFileList:
        if conv2html(file):
            echo file
            inc(genCount)
            sleep(tDelay)
    echo "Generated count = ", genCount

main()

