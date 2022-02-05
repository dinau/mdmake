# This file is referenced from
#   https://github.com/calganaygun/MDcat
#   https://github.com/calganaygun/MDcat/blob/main/template.html
#   2022/01
#
const TEMPLATE* = """
    <link
      href="https://unpkg.com/@primer/css@^16.0.0/dist/primer.css"
      rel="stylesheet"
    />
    <link rel="stylesheet alternate"
      href="https://cdn.jsdelivr.net/gh/primer/github-syntax-light@master/lib/github-light.css" id="light-hl">
    <link rel="stylesheet alternate"
    href="https://cdn.jsdelivr.net/gh/primer/github-syntax-dark@master/lib/github-dark.css" id="dark-hl">

    <title>$MD_TITLE</title>
  </head>

  <body id="markdown-body" data-color-mode="light" data-dark-theme="light">
    <div
      class="
        Box
        md
        js-code-block-container
        Box--responsive
        container-xl
        px-3 px-md-4 px-lg-5
        mt-5
      "
      id="content"
    >
      <div class="Box-body px-5 pb-5">
        <div class="d-flex flex-column flex-sm-row-reverse">
          <div>
            <button id="theme-button" class="btn" type="button">
              <span
                id="theme-icon"
                class="iconify"
                data-icon="octicon:sun-16"
              ></span>
            </button>
          </div>
        </div>
        <article class="markdown-body entry-content container-lg" itemprop="text">
            $MD_HTML
        </article>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/gh/calganaygun/MDcat@main/theme.js"></script>
    <script src="https://code.iconify.design/2/2.0.3/iconify.min.js"></script>
  </body>
"""

