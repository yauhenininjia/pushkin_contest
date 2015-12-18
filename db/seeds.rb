# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'open-uri'

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

end
