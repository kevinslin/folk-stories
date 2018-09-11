xml.instruct!
xml.rss(
  'xmlns:atom' => "http://www.w3.org/2005/Atom",
  'xmlns:itunes' => "http://www.itunes.com/dtds/podcast-1.0.dtd",
  'xmlns:googleplay' => "http://www.google.com/schemas/play-podcasts/1.0",
  'xmlns:content' => "http://purl.org/rss/1.0/modules/content/",
  'xmlns:media' => "http://search.yahoo.com/mrss/",
  'version' => "2.0"
) do
  xml.channel do
    xml.title podcast_name
    xml.atom :link, href: url(File.basename(__FILE__, '.builder')), rel: "self", type: "application/rss+xml"
    xml.description podcast_description_long
    xml.copyright "2018-#{Time.now.year} #{podcast_name}"
    xml.language "en-us"
    xml.link feedburner_url

    xml.image do
      xml.link feedburner_url
      xml.title podcast_name
      xml.url cover_art_url(:large)
    end

    xml.googleplay :author, podcast_name
    xml.googleplay :email, podcast_email
    xml.googleplay :image, href: cover_art_url(:large)

    xml.itunes :author, podcast_name
    xml.itunes :owner do
      xml.itunes :name, "Kevin S Lin"
      xml.itunes :email, "kevinslin8@gmail.com"
    end
    xml.itunes :explicit, "no"
    xml.itunes :image, href: cover_art_url(:large)
    xml.itunes :summary, podcast_description_long

    xml.itunes :category, text: "Society & Culture"
    xml.itunes :keywords, tags.join(',')

    episodes.each do |episode|
      xml.item do
        metadata = episode.data
        episode_text = strip_tags(episode.body)

        xml.title "#{metadata.episode}: #{metadata.title}"
        xml.link url(episode.url)
        xml.description metadata.summary
        xml.content :encoded, episode.body + picks_partial(episode) + partial(:shownotes_footer, locals: { episode: episode })
        xml.pubDate (episode.date + (15 * 60 * 60)).strftime("%a, %d %b %Y %H:%M:%S %z")
        xml.guid url(episode.url), isPermaLink: "true"
        xml.media :content, url: url(metadata.mp3), type: "audio/mpeg", fileSize: metadata.file_size
        xml.enclosure url: url(metadata.mp3), type: "audio/mpeg", length: metadata.file_size

        xml.itunes :subtitle, "Stories from People Around You"
        xml.itunes :summary, metadata.summary
        xml.itunes :author, podcast_name
        xml.itunes :explicit, "no"
        xml.itunes :duration, metadata.seconds
        xml.itunes :keywords, episode.tags.join(',')
        xml.itunes :image, href: cover_art_url(:large)
      end
    end
  end
end
