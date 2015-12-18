# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'open-uri'

POEMS_URL = 'http://rupoem.ru/pushkin/all.aspx'
doc = Nokogiri::HTML(open POEMS_URL)

doc.css('div.content').children.each do |div|
  title = div.css('h2.poemtitle').text
  body = div.xpath('pre').text.gsub /\r\n/, ' '

  Poem.create title: title, body: body
end

