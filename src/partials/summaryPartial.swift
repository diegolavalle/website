import SwiftySites

func summaryPartial(_ post: Post) -> String { """
<article class="summary">
    <header>
        <p class="date"><a href="\(post.path)">\(post.dateFormatted)</a> • <a href="/categories/\(post.categories.0)">\(post.categories.0.name)</a>, <a href="/categories/\(post.categories.1)">\(post.categories.1.name)</a></p>
        <h1 class="title">
            <a href="\(post.path)">\(post.title)</a>
            \(
                post.subtitle == .none
                ? ""
                : """
                <br />
                <a class="subtitle" href="\(post.path)">\(post.subtitle!)</a>
                """
            )
        </h1>
    </header>
    <main>
    \(post.summary)
    </main>
</article>
""" }
