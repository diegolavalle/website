import SwiftySites

let posts = [
    post_20240924_heterogeneous_json_arrays,
    post_20240722_counter_as_a_service,
    post_20221129_calling_mutating_async_functions,
    post_20220202_multiple_backend_environments,
    post_20220106_dockerizing_vapor_development,
    post_20211125_setting_text_field_focus,
    post_20211115_automating_swift_site_generation_netlify,
    post_20211111_urlsession_concurrency_linux,
    post_20210904_supporting_markdown
]

let site = Site(config,
    content: (
        [homePage, projectsPage, aboutPage, privacyPage, supportPage, categoriesPage],
        categories,
        posts
    ),
    template: (
        [pageTemplate, homeTemplate, categoriesTemplate],
        [categoryTemplate],
        [postTemplate]
    )
)

site.render()
