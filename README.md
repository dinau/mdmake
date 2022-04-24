<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Mdmake  : Converter of markdown files to html files with GFM](#mdmake---converter-of-markdown-files-to-html-files-with-gfm)
  - [GFM](#gfm)
  - [Prerequisite](#prerequisite)
  - [Build mdmake(.exe)](#build-mdmakeexe)
  - [Sample execution](#sample-execution)
  - [Usage](#usage)
  - [Example](#example)
  - [Referenced from](#referenced-from)
  - [Version info](#version-info)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Mdmake  : Converter of markdown files to html files with GFM

#### GFM
---

`GFM` means `Github Flavor Markdown`.

#### Prerequisite
---

1. Python 3.x or later
1. [doctoc](https://github.com/thlorenz/doctoc) : Index(TOC) generator

    ```
    npm install -g doctoc
    ```

1. [Nim][lk_nim] 1.6.x or later
1. [dos2unix](https://github.com/tizenorg/platform.upstream.dos2unix) command

#### Build mdmake(.exe)
---

```sh
nimble build
```

#### Sample execution
---

```sh
nimble sample
```

This will genarate **README.html** file.

#### Usage
---

- Specify `*.md` files

  ```sh
  mdmake Markdown file[s]
  ```

- Specify Directories that include `*.md` files

  ```sh
  mdmake dir[s]
  ```
- Specify folder names in `mdmake.dir` file.  
  All `*.md` files will be convert to html files in the directory that listed in `mdmake.dir` file.

  ```sh
  mdmake
  ```

#### Example
---

```sh
mdmake README.md test.md
```

This will generate `README.html` and `test.html`.

#### Referenced from
---

1. [MDcat][lk_mdcat]: Markdown converter  
  The `template_mdmake.nim` file used by this project is equal to MDcat `template.html` file. 

#### Version info
---

| mdmake | [nim][lk_nim] | doctoc            | dos2unix |
| :---:  | :------:      | :---:             | :---:    |
| 0.6.1  | nim-1.6.5     | 2022/01 installed | -        |

[lk_mdcat]:https://github.com/calganaygun/MDcat
[lk_nim]:https://nim-lang.org


