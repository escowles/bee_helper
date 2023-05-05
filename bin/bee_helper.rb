#!/usr/bin/env ruby

require "date"
require "faraday"
require "nokogiri"

# read words list from file
@words = ARGF.each.collect(&:strip)
def word_count(letter, length)
  @words.select { |w| w.start_with?(letter) && w.length == length }.count
end

# download new hints.html if it doesn't exist or is stale
hints = "#{__dir__}/../tmp/hints.html"
if !File.exists?(hints) || File.mtime(hints).day != Time.now.day
  puts "downloading today's hints..."
  today = Time.now.strftime("%Y/%m/%d")
  url = "https://www.nytimes.com/#{today}/crosswords/spelling-bee-forum.html"
  response = Faraday.get(url)
  File.open(hints, "wb") { |f| f.write(response.body) }
end

# parse hints.html file
hints = File.open(hints) { |f| Nokogiri::XML(f) }

# output list of two-letter pairs with number of words found out of the total
tll = hints.xpath("//p[@style='text-transform: uppercase;']/span/text()").map do |s|
  s.to_s.scan(/[a-z]{2}-\d+/)
end.flatten
tll.each do |freq|
  pair, n = freq.split("-")
  found = @words.select { |w| w.start_with?(pair) }.count
  puts "#{pair}-#{found}/#{n}" unless n.to_i == found
end

# output a grid of words found by letter and word length
table = {}
keys = []
hints.xpath("//table/tr").each do |row|
  values = row.xpath("./td//text()").map { |v| v.to_s }
  data = values[1..-2]
  if keys.empty?
    keys = data
  else
    letter = values.first
    unless letter.start_with?("&")
      data = data[1..-1].map { |v| v == "-" ? 0 : v.to_i }
      table[letter] = keys.zip(data).to_h
    end
  end
end

total_words = 0
total_found = 0

just = 6
print "    "
table.first[1].each do |v|
  print v[0].ljust(just)
end
puts
table.each_pair do |k, v|
  print "#{k}: "
  v.each_pair do |k2, v2|
    count = word_count(k, k2.to_i)
    total_words += v2
    total_found += count
    val = "#{count}/#{v2}"
    if count == v2
      print val.ljust(just)
    else
      print "\e[31m#{val.ljust(just)}\e[0m"
    end
  end
  print " #{total_found}/#{total_words}" if k == table.keys.last
  puts
end
