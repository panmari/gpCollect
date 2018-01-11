# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://gpcollect.duckdns.org"

SitemapGenerator::Sitemap.create do

  Category.find_each.each do |category|
    add(category_path(category, locale: I18n.default_locale),
        changefreq: 'yearly',
        lastmod: category.updated_at,
        alternates: I18n.available_locales.reject {|l|
                        l == I18n.default_locale}.map { |l|
                        { lang: l, href: category_url(category, locale: l)}
        })
  end
end
