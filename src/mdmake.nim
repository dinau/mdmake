# Mdmake -- *.md ファイルを .htmlファイルに変化するコンバータ
# 入力の*.mdファイルはUTF-8/LF(Unix)が前提
# 最初に見つかった "#"で始まる 行をタイトル文字列とする
#
# first:2021/12 by audin
# nim-1.6.2

const DEBUG = false
const UsePeg = true

when UsePeg: import pegs else: import strscans
import std/[os,strutils,osproc]
import md2htmlg, hashlib
import template_mdmake # $MD_TITLE $MD_HTML

const VERSION {.strdefine.}: string = "ERROR:unkonwn version"
const REL_DATE {.strdefine.}: string = "ERROR:unkonwn release date"

echo "[ Mdmake v$# --- $# ]" % [VERSION,REL_DATE]

const MD_FILENAME_OF_DIR_LIST= "mdmake.dir"
const MD_TEMP_FILENAME = "00temp.md" # *.exeがあるフォルダに生成される

when defined(windows):
    const cmdDoctoc = "doctoc.cmd"
else:
    const cmdDoctoc = "doctoc"

let html4header = """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "https://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta https-equiv="Content-Type" content="text/html; charset=utf-8">
"""
let htmlEnd = "</html>"

proc execCmdLocal(cmd:string):(string,int) =
    when true:
        #execCmdEx(cmd, options = {poStdErrToStdOut, poUsePath}) # poStdErrToStdOutは必須
        execCmdEx(cmd, options = { poUsePath}) # poStdErrToStdOutは必須
    else:
        discard execShellCmd(cmd)
        return ("",0)

proc conv2html(mdname: string): bool = # True: HTMLに変換した , False: 未変換(何もしない)
    var
        seqMsg: seq[string]
        gReqDos2unix = false
        sHtml,sCmd:string
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
    # *.mdファイルで最初に見つかった "#.." の行をhtmlタイトルとして取得する
    ################
    # '#'が行頭に1個以上あれば良い
    for line in lines(mdFilename):
        when UsePeg:
            if line =~ peg"'#'+ \s+ {.+}":
                sTitle = matches[0]
                break
        else:
            var (res,_,title) = scanTuple(line,"#$+ $s$+$.")
            if res:
                sTitle  = title
                break

    ################
    # include ファイル(*.mdi)をインクルードする
    ################
    # <!-- include "filename.mdi" --> と記述する
    block:
        var sMd:string
        for line in lines(mdFilename):
            var mdiName:string
            var res:bool
            when UsePeg:
                if line.strip =~ peg"'<!--'  \s+ 'include' {@} '-->' ":
                    mdiName = matches[0]
            else:
                (res,mdiName) = scanTuple(line,"$s<!--$sinclude$s$+-->")
            if mdiName != "":
                var sIncName = mdiName.strip(chars = {' ','"'})
                let paths = mdFilename.splitFile()
                # 絶対パス化 *.mdファイルと同じフォルダにあると決め打ちする
                sIncName = os.joinPath(paths.dir , sIncName)
                if fileExists(sIncName):
                    sMd &= readfile(sIncName) # Includeファイルの中身を結合
            else:
                sMd &= line & '\n'
        # Includeを反映したものを MD_TEMP_FILENAME として保存
        writeFile(MD_TEMP_FILENAME,sMd)

    ################
    # 目次を[doctoc]で*.mdファイルに追加
    ################
    # https://qiita.com/yumenomatayume/items/d20384da3d7a2fc49967
    # $ npm install -g doctoc
    if "" != findExe(cmdDoctoc):
        # includeを反映した目次をMD_TEMP_FILENAMEに作る
        sCmd = cmdDoctoc & " --github --notitle " & MD_TEMP_FILENAME
        discard execCmdLocal(sCmd)
        # オリジナル*.mdファイルの目次をアップデートしておく
        sCmd = cmdDoctoc & " --github --notitle " & mdFilename
        discard execCmdLocal(sCmd)

    ################
    # Github APIでHtmlに変換
    ################
    when UsePuppyLib:
        sHtml = md2htmlPuppy(readFile(MD_TEMP_FILENAME))
    else:
        sHtml = md2htmlg(readFile(MD_TEMP_FILENAME))
    if sHtml == "":
        echo "\n -- [ERROR:Server error !!! ] ---: ", MD_TEMP_FILENAME
        return false
    os.removeFile(MD_TEMP_FILENAME) # 一時ファイルを削除

    ################
    # md,html: 暫定: doctocで改行コードがおかしくなる場合をdos2unixで回避
    ################
    if gReqDos2unix: # Hashがない場合(初回)だけ
        if "" != findExe("dos2unix"):
            writeFile(htmlName, sHtml) # 一旦 htmlファイルに保存(dos2unixをかけるため)
            ###
            sCmd = "dos2unix -k $#" % [htmlName] # *.html
            discard execCmdLocal(sCmd)
            sCmd = "dos2unix -k $#" % [mdFilename] # *.md
            discard execCmdLocal(sCmd)
            ###
            sHtml = readFile(htmlName) # dos2unix後のhtmlファイルを再読込

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
    # htmlファイルをテンプレートと結合
    ################
    sHtml = html4header & TEMPLATE
        .replace("$MD_HTML", sHtml)
        .replace("$MD_TITLE", sTitle) & htmlEnd

    ################
    # シーケンスに変換 (行単位で処理するため)
    ################
    var seqHtml = splitLines(sHtml, keepeol = true)
    writefile("org.html",seqHtml.join("\n"))

    ################
    # 生成されたhtmlファイルを加工修正 orz
    ################
    block:
        # 目次のジャンプ先が"href=#TOC_LABEL1"になっていてジャンプできないので
        # "href=#user-content-TOC_LABEL1"に変更
        var
            sCap:string
            iCap:int
            mc:array[2,string]
        for i, line in seqHtml:
            #echo "<$#>" % [$i]
            when UsePeg:
                if line.strip =~ peg"'<h'[1-9]'>'":
                    iCap = 0
                    break
                if line.contains(peg(" '<li><a href=\"#' {.+}"),mc):
                    sCap = mc[0]
                    seqHtml[i] = "<li><a href=\"#" & "user-content-" & sCap
                    continue
                if line.contains(peg(" '<a href=' '\"' '#' {.+}"), mc):
                    sCap = mc[0]
                    seqHtml[i] = "<a href=\"#" & "user-content-" & sCap
                    continue
            else:
                var res:bool
                (res,iCap) = scanTuple(line,"$s<h$i>")
                if res:
                    iCap = 0
                    break
                (res, sCap) = scanTuple(line,"<li><a href=\"#$+$.")
                if res:
                    seqHtml[i] = "<li><a href=\"#" & "user-content-" & sCap
                    continue
                (res,sCap) = scanTuple(line,"<a href=\"#$+$.")
                if res:
                    seqHtml[i] = "<a href=\"#" & "user-content-" & sCap
                    continue

        # 画像ファイルがgithubのキャッシュ参照になってしまうのを修正
        for i, line in seqHtml:
            when UsePeg:
                if line.contains(peg("'data-canonical-src=\"' {@} [\"] ' style' .+  "), mc):
                    seqHtml[i] = "<p><img src=\"" & mc[0] & "\"></p>"
            else:
                let (res, _,sCap) = scanTuple(line,"$+data-canonical-src=\"$+\"$sstyle")
                if res:
                    seqHtml[i] = "<p><img src=\"" & sCap & "\"></p>"

    ###################################
    # html ファイルはこれ以降変更されない
    ###################################

    ################
    # htmlファイルに保存
    ################
    writeFile(htmlName, seqHtml.join)
    result = true

proc main() =
    var
        mdFileList: seq[string] # *.mdファイルのリストを保持
        mdDirList: seq[string]  # *.mdファイルがあるフォルダのリストを保持
        tDelay = 1 # [msec] 連続処理するとサーバに蹴られるのでテキトーなウエイトを入れる
                   # 連続禁止じゃなくて認証未登録の場合,1時間当たり60個までの様だ
                   # 登録すれば 5000個/h らしい
    if os.paramCount() > 0:
        # *.mdファイルとディレクトリをコマンドライン引数から取得
        for file in os.commandLineParams():
            if dirExists(file): mdDirList.add file
            if fileExists(file): mdFileList.add file
            #else: echo "Error: ファイル or フォルダがない [$#]" % [file]
    elif fileExists(MD_FILENAME_OF_DIR_LIST):
        # 「外部ファイル(mdmake.dir)内で指定された」フォルダリストからフォルダ名を取得
        for dirname in lines(MD_FILENAME_OF_DIR_LIST):
            mdDirList.add dirname

    for dirname in mdDirList: #複数フォルダ内の*.mdファイルを全部取得する(非再帰)
        if dirExists(dirname):
            for file in os.walkFiles(os.joinpath(dirname, "*.md")):
                mdFileList.add file

    var genCount = 0 # 処理したファイル数
    when false:
        if mdFileList.len <= 2: # 2個までは連続処理してみる
            tDelay = 0 # No wait
    var seqOkList: seq[string]
    let total = mdFileList.len
    for fname in mdFileList:
        when UsePeg:
            if fname.splitFile.name =~ peg"@ 'mail' @$":
                echo "[DENID!] ---- ",fname
                continue
        else:
            let (res,_,_) = scanTuple(fname.splitFile.name,"$*mail$*")
            if res:
                echo "[DENID!] ---- ",fname
                continue
        if conv2html(fname):
            echo fname
            inc(genCount)
            sleep(tDelay)
    for fname in seqOkList:
            echo fname
    echo "Generated count = $#/$#" % [$genCount, $total]

main()

