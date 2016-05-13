# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://gpcollect.duckdns.org"

SitemapGenerator::Sitemap.create do

  Category.find_each.each do |category|
    add(category_url(category, locale: I18n.default_locale),
        changefreq: 'yearly',
        lastmod: category.updated_at,
        alternates: [{
                          lang: 'en', href: category_url(category, locale: 'en')}
        ])
  end
end
