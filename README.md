<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Mdmake  : Converter of markdown files to html files with GFM](#mdmake---converter-of-markdown-files-to-html-files-with-gfm)
  - [GFM](#gfm)
  - [Prerequisite](#prerequisite)
  - [Build mdmake(.exe)](#build-mdmakeexe)
  - [Sample execution](#sample-execution)
  - [Usage](#usage)
  - [Example](#example)
  - [Language 言語色分けテスト](#language-%E8%A8%80%E8%AA%9E%E8%89%B2%E5%88%86%E3%81%91%E3%83%86%E3%82%B9%E3%83%88)
    - [Ruby](#ruby)
    - [Nim](#nim)
    - [Zig](#zig)
  - [Referenced from](#referenced-from)
  - [Version info](#version-info)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Mdmake  : Converter of markdown files to html files with GFM

#### GFM

`GFM` means `Github Flavor Markdown`.

#### Prerequisite

1. Python 3.x or later
1. [doctoc](https://github.com/thlorenz/doctoc) : Index(TOC) generator

    ```
    npm install -g doctoc
    ```

1. [Nim][lk_nim] 1.6.x or later
1. [dos2unix](https://github.com/tizenorg/platform.upstream.dos2unix) command

#### Build mdmake(.exe)

```sh
nimble build
```

#### Sample execution

```sh
nimble sample
```

This will genarate **README.html** file.

#### Usage

- Specify `*.md` files

  ```sh
  mdmake [Markdown files]
  ```

- Specify folder names in `md-dir.list` file.  
  All `*.md` files will be convert to html files in the directory that listed in `md-dir.list` file,  
  then,

  ```sh
  mdmake
  ```

#### Example

```sh
mdmake README.md test.md
```

This will generate `README.html` and `test.html`.

#### Language 言語色分けテスト

##### Ruby

```Ruby
def test(a,b)
    print "hello"
end
```

##### Nim

```Nim
proc foo(var:uint32) : uint8 =
    return var * 34
```

##### Zig

```Zig
const std = @import("std")
```


#### Referenced from

1. [MDcat][lk_mdcat]: Markdown converter  
  The `template_mdmake.nim` file used by this project is equal to MDcat `template.html` file. 

#### Version info

| mdmake | [nim][lk_nim] | doctoc            | dos2unix |
| :---:  | :------:      | :---:             | :---:    |
| 0.5.0  | nim-1.6.2     | 2022/01 installed | -        |

[lk_mdcat]:https://github.com/calganaygun/MDcat
[lk_nim]:https://nim-lang.org


