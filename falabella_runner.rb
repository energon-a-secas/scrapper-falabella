require 'notify-energon'
require_relative 'falabella_scrapper'
require_relative 'falabella_firestore'

dji_air = 'https://www.falabella.com/falabella-cl/search?Ntt=dji+air'
dji_mavic = 'https://www.falabella.com/falabella-cl/search?Ntt=mavic+pro&sortBy=derived.price.search%2Cdesc&f.product.attribute.Tipo=Drones+profesionales&f.product.brandName=dji'
dji_phantom = 'https://www.falabella.com/falabella-cl/search?Ntt=dron+phantom'
falabella_products = [dji_mavic, dji_phantom, dji_air]

slack_name = 'Dron'
slack_channel = 'hq-t-scl-drones'
slack_image_url = 'https://img.icons8.com/pastel-glyph/2x/drone-with-camera--v1.png'

falabella = FalabellaScrapper.new
firebase = FalabellaFireStore.new

n = NotifyEnergon.new(slack_enabled: true, name: slack_name, image: slack_image_url)

falabella_products.each do |search|
  product_list = falabella.get_href_from(search, 'product')
  product_list.each do |link|
    item_name = ''
    url_match = link.match(%r{(\d{5,})/(.*)/(\d{5,})$})
    item_name = url_match[2] unless url_match.nil?
    item_id = url_match[3] unless url_match.nil?
    item_price = falabella.price_search(link).join('-')

    saved_item_price = firebase.get_document("stores/falabella/drones/#{item_name}-#{item_id}")
    firebase.store_set('falabella', 'drones', "#{item_name}-#{item_id}")

    text = ''
    if saved_item_price.exists? != true
      text = 'ha sido agregado a la DB.'
      firebase.item_set(item_name, item_price, link)
    else
      if item_price != saved_item_price[:price]
        item = saved_item_price[:price]
        item = 'agotado' if item.empty?
        text = "ha sido actualizado de #{item} a #{item_price}."
        text = 'Agotado' if item_price.empty?
        firebase.item_set(item_name, item_price, link)
      end
    end
    unless text.empty?
      n.send_message("📦 Falabella <#{link}|#{item_name}> #{text}", slack_channel)
    end
  end
end
