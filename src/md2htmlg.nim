# 2022/12: Added: Puppy library
# 2022/01 by audin

import std/[json,os,strutils]

const UsePuppyLib* {.booldefine.}: bool = true

# Github GFM API: Makdown to Html Converter
const URL = "https://api.github.com/markdown"

######################
## Using Puppy library
######################
import puppy
var header1 =  @[Header(key:"Accept"      ,value:"application/vnd.github.v3+json"),
                 Header(key:"Content-Type",value:"application/json"), ]

const ACSTokenFile = "githubAccessToken.token"
if fileExists(ACSTokenFile):
    for line in lines(ACSTokenFile):
        let sLine = line.strip
        if (sLine == "") or (sLine[0] == '#'): break
        let sAcsToken = "bearer " &  sLine
        header1.add Header(key:"Authorization:", value:"\"$#\"" % [sAcsToken])
        break # only get first line

proc md2htmlPuppy*(sMdFile:string):string =
    let req = Request( # HTTP request
        url: parseUrl(URL),
        verb: "post",
        body: $(%*{"text": sMdFile}),
        headers: header1
    )
    let res = fetch(req)
    if res.code == 200:
        result = res.body
    else:
        echo "Server response error !! ", res.body
        result = ""

#####################
## Using Std library
#####################
import std/[httpclient]
const HEADER2 = {"Accept": "application/vnd.github.v3+json",
                 "Content-Type": "application/json"}

proc md2htmlg*(sMdFile:string):string =
    let client = newHttpClient()
    client.headers = newHttpHeaders(HEADER2)
    let body = %*{"text": sMdFile}
    # HTTP request
    let response = client.request(URL, httpMethod = HttpPost, body = $body)
    if response.status == "200 OK":
        result = response.body
    else:
        echo "Server response error !! ", response.status
        result = ""

#####################
## main()
#####################

when isMainModule:
    import std/[pegs]
    import template_mdmake

    let html4header = """
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "https://www.w3.org/TR/html4/loose.dtd">
    <html><head>
    <meta https-equiv="Content-Type" content="text/html; charset=utf-8">
    """
    let htmlEnd = """
    </html>
    """
    proc main() =
        if os.paramCount() < 1:
            echo "Argument error !!! Specify *.md file name"
            quit 1
        # *.mdファイルをコマンドライン引数から取得
        let mdFilename = os.commandLineParams()[0]
        if not os.fileExists(mdFilename):
            echo "!Error ファイルがありません [$#]" % [mdFilename]
            quit 1
        # 最初に見つかった1つ以上の"#"のあとをタイトル文字列とする
        # (後でHTMLファイルに埋め込む)
        let sMdFile = readFile(mdFilename)
        var sTitle = ""
        if  sMdFile =~ peg"@ '#'+ \s+ {@} \n ":
            sTitle = matches[0]
        when UsePuppyLib:
            let sHtml = md2htmlPuppy(sMdFile)
        else:
            let sHtml = md2htmlg(sMdFile)
        # HTMLひな形に埋め込む
        let str = html4header & TEMPLATE
                .replace("$MD_HTML",sHtml)
                .replace("$MD_TITLE",sTitle) & htmlEnd
        # Convert *.md to *.html
        let saveName = changefileExt(mdfilename,".html")
        writeFile(saveName,str)

    ###########
    # main()
    ###########
    main()

