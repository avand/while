json.array!(@items) do |item|
  json.extract! item, :id, :name, :parent_item_id, :completed
  json.url item_url(item, format: :json)
end
