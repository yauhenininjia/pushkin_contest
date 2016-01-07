# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'open-uri'
=begin
PUSHKIN_URL = 'http://rvb.ru/pushkin/'
volumes_url = %w(http://rvb.ru/pushkin/tocvol1.htm http://rvb.ru/pushkin/tocvol2.htm)
volumes_url.each do |url|
  doc = Nokogiri::HTML(open url)
  begin
    a = doc.xpath('//table//td/a').each do |a|
      title = a.text
      poems = Nokogiri::HTML(open PUSHKIN_URL + a[:href])

      body = ''
      poems.xpath("//span[@class='line' or @class='line2r']").each do |line|
        body += "#{line.text}\n"
      end
      poem = Poem.new title: title, body: body
      poem.save
    end
  rescue OpenURI::HTTPError => e
    if e.message == '404 Not Found'
      puts '-' * 80
    else
      raise e
    end
  end
=end

    URL = "http://ilibrary.ru/text/"

    mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Linux Firefox'
    }

    page = mechanize.get("http://ilibrary.ru/author/pushkin/l.all/index.html")
    links = page.parser.css('.list a')

    id_poems = links.map { |l| l.attributes['href'].value }
      .select { |l| l =~ %r{/text/\d+/index\.html} }
      .map { |l| l.scan(/\d+/)[0] }.uniq

    num = 0
    size = id_poems.size
    puts "About to write #{size} poems..."

    #Poem.delete_all

    id_poems.each do |id|
      link = URL + id + "/p.1/index.html"

      page = mechanize.get(link)

      title = page.parser.css('.title h1').text
      text = page.parser.css('.poem_main').text
      text.gsub!(/\u0097/, "\u2014") # replacement of unprintable symbol
      text.gsub!(/^\n/, "") # remove first \n

      puts "="*30
      puts title
      puts text
      puts "#{num} of #{size}"
      num += 1

      next if text.blank?

      poem = Poem.new
      poem.title = title
      poem.body = text
      poem.save
end
