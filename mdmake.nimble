# Package

version       = "0.9.1"
author        = "dinau"
description   = "Converter of markdown file to html file for my blog page"
license       = "MIT"
srcDir        = "src"
bin           = @["mdmake"]


# Dependencies

requires "nim >= 1.6.2"

const UsePuppyLib = true

when UsePuppyLib:
    requires "puppy >= 1.6.2"
    switch "define","UsePuppyLib=$#" % [$UsePuppyLib]
else:
    switch "define","ssl"

task sample,"run":
    exec "./mdmake " & "README.md"

