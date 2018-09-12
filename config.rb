require 'active_support/core_ext/integer/inflections'

Slim::Engine.disable_option_validator!

def is_prod
  ENV['S3_BUCKET'] == 'kevinslin-ft'
end

def is_staging
  ENV['S3_BUCKET'] == 'kevinslin-ft-staging'
end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :relative_links, true

set :slim, layout_engine: :slim

page '/podcast.xml', layout: false
page '/feed.xml', layout: false

activate :blog do |blog|
  blog.layout = "episode.html"
  blog.permalink = "{episode}"
  blog.publish_future_dated = true
  blog.sources = "episodes/{episode}.html"
  blog.tag_template = "tag.html"
  blog.taglink = "tag/{tag}"
end

configure :build do
  activate :asset_hash, exts: %w[css js]
  #activate :directory_indexes
  activate :minify_css
  activate :minify_javascript
  activate :relative_assets
end


if is_prod
  acl = 'public-read'
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-125239344-1'
  end
elsif is_staging
  acl = 'public-read'
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-125239344-2'
  end
else
  acl = 'authenticated-read'
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-125239344-2'
  end
end

activate :s3_sync do |s3_sync|
 s3_sync.bucket                     = ENV['S3_BUCKET'] # The name of the S3 bucket you are targetting. This is globally unique.
 s3_sync.region                     = 'us-west-2'     # The AWS region for your bucket.
 s3_sync.aws_access_key_id          = ENV['ACCESS_KEY']
 s3_sync.aws_secret_access_key      = ENV['SECRET_KEY']
 s3_sync.delete                     = true # We delete stray files by default.
 s3_sync.after_build                = false # We do not chain after the build step by default.
 s3_sync.prefer_gzip                = true
 s3_sync.path_style                 = true
 s3_sync.reduced_redundancy_storage = false
 s3_sync.acl                        = acl
 s3_sync.encryption                 = false
 s3_sync.version_bucket             = false
 s3_sync.index_document = 'index.html'
 s3_sync.error_document             = '404.html'
end

helpers do
  def page_title
    return podcast_name unless current_page.data.title

    "#{podcast_name} ##{current_page.data.episode}: #{current_page.data.title}"
  end

  def page_description
    return podcast_description unless current_page.data.tweet_text

    current_page.data.tweet_text
  end

  def fb_image
    url '/banner.png'
  end

  def twitter_image
    url '/twitter-card.jpg'
  end

  def cover_art_path(size = :medium)
    {
      small: "/cover-art-128.png",
      medium: "/cover-art-512.png",
      large: "/cover-art-1400.png"
    }[size]
  end

  def cover_art_url(*args)
    url(cover_art_path(*args))
  end

  def episodes
    blog.articles
  end

  def format_date(time)
    time.strftime("%B #{time.day.ordinalize}, %Y")
  end

  def picks_partial(episode)
    partial "picks", locals: { episode_picks: episode.data['picks'] }
  end

  def rss_url
    "/podcast.xml"
  end

  def about_url
    "/about.html"
  end

  def mail_list_url
    "TODO"
  end

  def feedburner_url
    "http://feeds.feedburner.com/folkstories/xbiK"
  end

  def github_url
    "https://github.com/turing-incomplete/turing-incomplete"
  end

  def google_play_url
    "https://play.google.com/music/m/Igqjukscruowpmyxau526hg6t2u?t=Folk_Stories"
  end

  def stitcher_url
    "https://www.stitcher.com/podcast/kevin-s-lin/folk-stories"
  end

  def tunein_url
  end

  def itunes_url
    "https://itunes.apple.com/us/podcast/folk-stories/id1435808877"
  end

  def podcast_author
    "Kevin S Lin"
  end

  def podcast_email
    "kevinslin8@gmail.com"
  end

  def podcast_name
    "Folk Stories"
  end

  def podcast_description
    "Stories from people around you."
  end

  def podcast_description_long
    "This is a podcast about people. Every week, we have an in depth conversation with a person of interest. We'll talk about how they got here, what they're up to and why they do what they do. The aim is to collect narratives from people from all walks of lives, ranging from tech CEOs to Film Directors and Irish Folk Singers. Folk Stories is meant to be a platform to hear their stories, learn their lessons and explore what its like to walk a day in their shoes."
  end

  def stickers_url
    "https://www.stickermule.com/marketplace/4818-turing-incomplete"
  end

  def tags
    blog.tags.keys.sort
  end

  def title
    [
      podcast_name,
      current_page.data.title || yield_content(:title)
    ].compact.join(" - ")
  end

  def twitter_url
    "https://twitter.com/kevins8"
  end

  def url(path = "")
    path = path.gsub(/^\//, '')

    "http://folkstories.org/#{path}"
  end
end
