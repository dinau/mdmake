# Package

version       = "0.6.2"
author        = "dinau"
description   = "Converter of markdown file to html file for my blog page"
license       = "MIT"
srcDir        = "src"
bin           = @["mdmake"]


# Dependencies

requires "nim >= 1.6.2"

task sample,"run":
    exec "./mdmake " & "README.md"

