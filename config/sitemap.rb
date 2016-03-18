# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://gpcollect.duckdns.org"

SitemapGenerator::Sitemap.create do
  Runner.find_each.each do |runner|
    add runner_path(runner), :changefreq => 'yearly', :lastmod => runner.updated_at
  end
end
