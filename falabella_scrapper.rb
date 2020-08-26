require 'nokogiri'
require 'rest-client'
require_relative 'falabella_firestore'

# Scrapper of href elements
class FalabellaScrapper
  def initialize; end

  def get_html_from(url)
    response = RestClient.get url
    Nokogiri::HTML(response)
  end

  def get_href_from(url, regex, path = '//div/a/@href')
    href_list = []
    parsed_page = get_html_from(url)
    parsed_page.xpath(path).each do |v|
      url = v.text
      check = url.match(/#{regex}/)
      href_list << url if check
    end
    href_list
  end

  def price_search(url)
    parsed_page = get_html_from(url)
    price = []
    parsed_page.css('li').map do |v|
      unless v.values[1].nil?
        price << v.values[0] if v.values[1].include? 'price'
      end
    end
    price
  end
end
