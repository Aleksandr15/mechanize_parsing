require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'date'
require 'json'
require 'pry'

agent = Mechanize.new
page = agent.get("https://web.archive.org/web/20150214074303/http://www.pitchfork.com/reviews/albums")
review_links = page.links_with(href: %r{/reviews/albums/\w++})
review_links = review_links.reject do |link|
  parent_classes = link.node.parent['class'].split
  parent_classes.any? {|p| %w[next-container page-number].include? (p)}
end

review_links = review_links[0...4]
#binding pry

reviews = review_links.map do |link|
  review = link.click
  review_meta = review.search('#main .review-meta .info')
  artist = review_meta.search('h1')[0].text
  album = review_meta.search('h2')[0].text
  label,year = review_meta.search('h3')[0].text.split(';').map(&:strip)
  reviewer = review_meta.search('h4 address')[0].text
  review_date = Date.parse(review_meta.search('.pub-date')[0].text)
  score = review_meta.search('.score').text.to_f

  {
    artist: artist,
    album: album,
    label: label,
    reviewer: reviewer,
    review_date: review_date,
    score: score
  }
end

puts JSON.pretty_generate(reviews)
