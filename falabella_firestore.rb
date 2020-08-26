require 'google/cloud/firestore'

# Methods for Firestore operations
class FalabellaFireStore
  def initialize
    @client = Google::Cloud::Firestore.new
  end

  def get_document(document)
    doc_ref = @client.doc(document)
    doc_ref.get
  end

  def store_set(doc_name, sub_col, doc_item = 'dji', main_col = 'stores')
    @doc_ref = @client.doc("#{main_col}/#{doc_name}/#{sub_col}/#{doc_item}")
  end

  def item_set(model, price, link)
    @doc_ref.set(
      model: model,
      price: price,
      link: link
    )
  end

  def store_search(col = 'stores')
    stores = @client.col col
    available_stores = []
    stores.get do |user|
      available_stores << user.document_id
    end

    available_stores.each do |v|
      store = @client.col "#{col}/#{v}/drones"
      store.get do |i|
        p "#{v} #{i.data[:model]}"
      end
    end
  end
end
