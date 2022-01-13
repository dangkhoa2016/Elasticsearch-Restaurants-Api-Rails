

-- update some records and check aggs again

rr = client.search({ index: 'restaurants2', size: 2 })
restaurants = rr["hits"]["hits"].map { |r| { id: r["_id"], s: r["_source"].dup } }
restaurants.map { |r| r[:s]["published_on"] }
restaurants.map { |r| r[:s]["published_on"] = Time.now.utc.iso8601(3) }
rr["hits"]["hits"].map { |r| r["_source"]["published_on"] }

body = (restaurants.map { |r| [{ index: { _index: 'restaurants2', _id: r[:id] } }, r[:s]] }).flatten
client.bulk({ refresh: true, body: body })
restaurants.map { |r| r[:id] }

client.search({ index: 'restaurants2',
  body: {
    query: {
      ids: {
        values: restaurants.map { |r| r[:id] }
      }
    },
    _source: 'published_on'
  }
})

rr = client.search({
  index: 'restaurants2',
  body: { "size": 6, "sort": [{ "published_on": "asc" }] }
})
restaurants = rr["hits"]["hits"].map { |r| { id: r["_id"], s: r["_source"].dup } }
restaurants.map { |r| r[:s]["published_on"] = Time.now.utc.iso8601(3) }

body = (restaurants.map { |r| [{ index: { _index: 'restaurants2', _id: r[:id] } }, r[:s]] }).flatten
client.bulk({ refresh: true, body: body })
restaurants.map { |r| r[:id] }

--- 
