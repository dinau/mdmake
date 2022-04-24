# 2022/01 by audin
#
{.push warning[UnusedImport]: off.}
include std/prelude
import std/[ httpclient, json]

const URL = "https://api.github.com/markdown"
const HEADER = {"Accept": "application/vnd.github.v3+json",
                 "Content-Type": "application/json"}
################
## md2htmlg()
################
proc md2htmlg*(sMdFile:string):string =
    # HTTP request
    let client = newHttpClient()
    client.headers = newHttpHeaders(HEADER)
    let body = %*{"text": sMdFile}
    let response = client.request(URL, httpMethod = HttpPost, body = $body)
    if response.status == "200 OK":
        result = response.body
    else:
        echo "Server response error !! ", response.status
        result = ""


when isMainModule:
    ################
    ## test_main()
    ################
    import std/pegs
    let html4header = """
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "https://www.w3.org/TR/html4/loose.dtd">
    <html><head>
    <meta https-equiv="Content-Type" content="text/html; charset=utf-8">
    """
    let htmlEnd = """
    </html>
    """
    const POSTFIX = "-md2htmlg"
    const TEMPLATE = "template.html"

    proc test_main() =
        if os.paramCount() < 1:
            echo "Argument error !!! Specify *.md file name"
            echo "Markdown converter to Html file"
            echo "\nUsage:"
            echo "\n  $ md2htmlg [*.md files]"
            quit 1
        # *.mdファイルをコマンドライン引数から取得
        for arg in os.commandLineParams():
            let mdFilename = absolutePath(arg)
            if not os.fileExists(mdFilename):
                echo "!Error ファイルがありません [$#]" % [mdFilename]
                continue
            # 最初に見つかった1つ以上の"#"のあとをタイトル文字列とする
            var sTitle = ""
            var mc:array[1,string]
            for line in lines(mdFilename):
                if line.contains(peg(" '#'+ ' ' {.+}"),mc):
                    sTitle = mc[0]
                    break
            let paths = mdFilename.splitFile
            let sHtml = md2htmlg(readFile(mdFilename))
            let saveName = os.joinPath(paths.dir, paths.name & POSTFIX & ".html")
            if fileExists(TEMPLATE):
                let str = html4header & readFile(TEMPLATE)
                    .replace("$MD_HTML",sHtml)
                    .replace("$MD_TITLE",sTitle) & htmlEnd
                writeFile(saveName,str)
            else:
                writeFile(saveName,sHtml)

    test_main()

