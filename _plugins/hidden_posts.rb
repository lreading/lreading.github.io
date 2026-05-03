module HiddenPosts
  def self.hidden?(item)
    if item.respond_to?(:data)
      item.data["hidden"]
    elsif item.respond_to?(:[])
      item["hidden"]
    end
  end
end

module HiddenPostsFilters
  def visible_posts(posts)
    Array(posts).reject { |post| HiddenPosts.hidden?(post) }
  end
end

Liquid::Template.register_filter(HiddenPostsFilters)

Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each do |post|
    post.data["sitemap"] = false if HiddenPosts.hidden?(post)
  end
end
