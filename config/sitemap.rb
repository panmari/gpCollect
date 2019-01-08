# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'http://gpcollect.duckdns.org'

OTHER_LOCALES = I18n.available_locales.reject { |l| l == I18n.default_locale }
SitemapGenerator::Sitemap.create do
  Category.find_each.each do |category|
    add(category_path(category, locale: I18n.default_locale),
        changefreq: 'yearly',
        lastmod: category.updated_at,
        alternates: OTHER_LOCALES.map { |l| { lang: l, href: category_url(category, locale: l) } })
  end
  Route.find_each.each do |route|
    add(route_path(route, locale: I18n.default_locale),
        alternates: OTHER_LOCALES.map { |l| { lang: l, href: route_url(route, locale: l) } })
  end
  add(participants_path(locale: I18n.default_locale),
      alternates: OTHER_LOCALES.map { |l| { lang: l, href: participants_path(locale: l) } })
end
