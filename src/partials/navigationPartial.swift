import SwiftySites

func navigationPartial(_ page: Page?) -> String { """
<nav>
    <ul>
        \([homePage, projectsPage].reduce("") {
            $0 + """
            <li>\(page?.path == $1.path
                ? """
                \($1.title)
                """
                : """
                <a href="\($1.path)">\($1.title)</a>
                """
            )</li>
            """
        })
    </ul>
</nav>
""" }
