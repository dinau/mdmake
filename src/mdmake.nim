# 2021/12 by audin
# nim-1.6.2
## 入力の*.mdファイルはUTF-8/LF(Unix)が前提
## 最初に見つかった "#"で始まる 行をタイトル文字列とする

const DEBUG = false

const MD_DIR_LIST_FILENAME = "mdmake.dir"

{.push warning[UnusedImport]: off.}
include std/prelude
import std/pegs
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
    var seqMsg: seq[string]
    var gReqDos2unix = false
    let mdFilename = absolutePath(mdname)
    let htmlname = mdFilename.changeFileExt(".html")

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

    var mc: array[4, string]
    var sTitle = "  "

    echo mdFilename
    # mdファイルの最初に見つかった #.. 行をhtmlのタイトルとする
    # '#'が行頭に1個以上あれば良い
    for line in lines(mdFilename):
        if line.contains(peg("'#'+ ' ' {.+}"), mc):
            sTitle = mc[0]
            break

    # 目次を[doctoc]で*.mdファイルに追加
    # https://qiita.com/yumenomatayume/items/d20384da3d7a2fc49967
    # $ npm install -g doctoc
    var sCmd: string
    if "" != findExe("doctoc"):
        when true:
            sCmd = "doctoc --github --notitle " & mdFilename
            discard execShellCmd(sCmd)

    # Github APIでHtmlに変換
    var sHtml = md2htmlg(readFile(mdFilename))
    if sHtml == "":
        echo "Server error !!! :", mdFilename
        return false
    # 一旦ファイルに保存(dos2unixをかけるため)
    writeFile(htmlName, sHtml)

    # 暫定: doctocで改行コードがおかしくなる場合をdos2unixで回避
    if gReqDos2unix: # Hashがない場合(初回)だけ
        if "" != findExe("dos2unix"):
            sCmd = "dos2unix $#" % [htmlName]
            discard execShellCmd(sCmd)
            sCmd = "dos2unix $#" % [mdFilename]
            discard execShellCmd(sCmd)

    ###################################
    # mdファイルはこれ以降変更されない
    ###################################
    discard saveHash(mdFilename) # mdファイルのHashを作って保存
    seqMsg.add "Hashを作って保存した"
    # デバッグ用出力
    when DEBUG:
        for str in seqMsg: echo str

    # dos2unix後を再読込
    sHtml = readFile(htmlName)
    # htmlファイルをテンプレートと結合
    sHtml = html4header & TEMPLATE
        .replace("$MD_HTML", sHtml)
        .replace("$MD_TITLE", sTitle) & htmlEnd

    # シーケンスに変換
    var seqHtml = splitLines(sHtml, keepeol = true)

    # 生成されたhtmlファイルを加工
    when true:
        # 目次のジャンプ先が"href=#TOC_LABEL1"になっていてジャンプできないので
        # "href=#user-content-TOC_LABEL1"に変更
        for i, line in seqHtml:
            if line.contains(peg("'<h'[1-9]'>'"), mc):
                break
            elif line.contains(peg("'<li><a href=' '\"' '#' {.+}"), mc):
                seqHtml[i] = "<li><a href=\"#" & "user-content-" & mc[0]
            elif line.contains(peg(" '<a href=' '\"' '#' {.+}"), mc):
                seqHtml[i] = "<a href=\"#" & "user-content-" & mc[0]
        # 画像ファイルがgithubのキャッシュ参照になってしまったのを修正
        for i, line in seqHtml:
            if line.contains(peg("'data-canonical-src=\"' {@} [\"] ' style' .+  "), mc):
                seqHtml[i] = "<p><img src=\"" & mc[0] & "\"></p>"

    # 文字列に変換
    sHtml = ""
    for line in seqHtml:
        sHtml &= line
    # html保存
    writeFile(htmlName, sHtml)
    result = true

proc main() =
    var
        mdFileList: seq[string] # *.mdファイルのリストを保持
        mdDirList: seq[string]  # *.mdファイルがあるフォルダのリストを保持
        tSlow = 1000 # [msec] 連続処理するとサーバに蹴られるのでテキトーなウエイトを入れる
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
            tSlow = 0 # No wait
    for file in mdFileList:
        if conv2html(file):
            echo file
            inc(genCount)
            sleep(tSlow)
    echo "Generated count = ", genCount

main()
