import SwiftySites

func baseLayout (page: Page? = nil, post: Post? = nil, main: String) -> String { """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="stylesheet" href="/assets/global.css" />
        <link rel="stylesheet" href="/assets/highlight.css" />
        <link id="themeCSSLink" rel="stylesheet" href="/assets/dark.css" media="(prefers-color-scheme: dark)" />
        <script src="https://cdn.jsdelivr.net/npm/vue@2"></script>
        <!--script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script-->
        <script src="https://cdn.jsdelivr.net/gh/swiftysites/theme-switch@release/src/theme-switch.min.js"></script>
        <script src="/assets/highlight.js"></script>
        <script>hljs.highlightAll();</script>
        <title>\(config.title) | \(page?.title ?? post!.title)</title>
    </head>
    <body>
        <header>
            <div>
                <div class="site-title">
                    <span class="name">Diego Lavalle</span> – Swift and Apple Platforms Development</div>
                \(navigationPartial(page))
            </div>
            <theme-switch stylesheet-id="themeCSSLink" color="#C41A16" color-dark="#FC6A5D"></theme-switch>
        </header>
        \(main)
        \(footerPartial(page))
        <script src="/assets/comments-app.js"></script>
    </body>
</html>
""" }
