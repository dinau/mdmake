# 2021/12 by audin
# nim-1.6.2
## 入力の*.mdファイルはUTF-8/LF(Unix)が前提
## 最初に見つかった "#"で始まる 行をタイトル文字列とする

import std/[os, pegs, strutils]
#
import md2htmlg,hashlib
import template_mdmake
# $MD_TITLE
# $MD_HTML

let html4header = """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "https://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta https-equiv="Content-Type" content="text/html; charset=utf-8">
"""
let htmlEnd = "</html>"

proc conv2html(mdname:string) :bool =
    var gReqDos2unix = false
    let mdFilename = absolutePath(mdname)
    let htmlname = mdName.changeFileExt(".html")

    block:
        if not os.fileExists(mdFilename):
            echo "!Error ファイルがありません [$#]" % [mdFilename]
            return
        # hash値が違うならHtmlファイルを再生成
        if not haveHashFile(htmlName): # Hashがない場合(初回)だけ
            gReqDos2unix = true

        if os.fileExists(htmlname) and isEqualHash(mdName):
            return
        else: # mdファイルのhash値が違う、又はHtmlファイルが存在しない
            discard saveHash(mdName) # Hashを更新

    var mc: array[4, string]
    var sTitle = "  "

    echo mdFilename
    # mdファイルの最初に見つかった #.. 行をhtmlのタイトルとする
    # '#'が行頭に1個以上あれば良い
    for line in lines(mdFilename):
        if line.contains(peg("'#'+ ' ' {.+}"), mc):
            sTitle = mc[0]
            break

    # 目次を[dotoc]で*.mdファイルに追加
    # https://qiita.com/yumenomatayume/items/d20384da3d7a2fc49967
    # $ npm install -g doctoc
    var sCmd:string
    if "" != findExe("doctoc"):
        when true:
            sCmd = "doctoc --github --notitle " & mdFilename
            discard execShellCmd(sCmd)

    # Github APIでHtmlに変換
    var sHtml = md2htmlg(readFile(mdFilename))
    if sHtml == "":
        echo "Server error !!! :",mdFilename
        return false
    # 一旦ファイルに保存(dos2unixをかけるため)
    writeFile(htmlName,sHtml)

    # 暫定: 改行コードがおかしくなる場合をdos2unixで回避
    if gReqDos2unix: # Hashがない場合(初回)だけ
        if "" != findExe("dos2unix"):
            sCmd = "dos2unix $#" % [htmlName]
            discard execShellCmd(sCmd)

    sHtml = readFile(htmlName) # dos2unix後を再読込
    # htmlファイルをテンプレートと結合
    sHtml = html4header & TEMPLATE
        .replace("$MD_HTML",sHtml)
        .replace("$MD_TITLE",sTitle) & htmlEnd

    # シーケンスに変更
    var seqHtml = splitLines(sHtml, keepeol = true)
    block:
        # 目次のジャンプ先が"href=#TOC_LABEL1"になっていてジャンプできないので
        # "href=#user-content-TOC_LABEL1"に変更
        for i,line in seqHtml:
            if line.contains(peg("'<h'[1-9]'>'"), mc):
                break
            elif line.contains(peg("'<li><a href=' '\"' '#' {.+}"), mc):
                let str = "<li><a href=\"#" & "user-content-" & mc[0]
                seqHtml[i] = str
            elif line.contains(peg(" '<a href=' '\"' '#' {.+}"), mc):
                let str = "<a href=\"#" & "user-content-" & mc[0]
                seqHtml[i] = str
    # 文字列に変更
    sHtml = ""
    for line in seqHtml:
        sHtml &= line
    # html保存
    writeFile(htmlName, sHtml)
    result = true

proc main() =
    const MD_DIR_LIST_FILENAME = "md-dir.list"
    var mdFilsList:seq[string]
    if os.paramCount() > 0:
        # *.mdファイルをコマンドライン引数から取得
        for file in os.commandLineParams():
            mdFilsList.add file
    # リストに書かれたフォルダ内の*.mdファイルを全部処理する
    elif fileExists(MD_DIR_LIST_FILENAME):
        for dirname in lines(MD_DIR_LIST_FILENAME):
            if dirExists(dirname):
                for file in os.walkFiles(os.joinpath(dirname, "*.md")):
                    mdFilsList.add file

    var genCount = 0 # 処理したファイル数
    for file in mdFilsList:
        if conv2html(file):
            echo file
            inc(genCount)
            sleep(500)
    echo "Generated count = ", genCount

main()
