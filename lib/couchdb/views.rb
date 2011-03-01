require_relative '../../config/couchdb_setup'

@db = CONFIG[:couchdb]

user_views = {
  "emails" => {
    "map" => <<-MAP
      function(doc) {
        if(doc.email) {
          emit(doc.email, doc)
        }
      }
    MAP
  },
  "email_from_token" => {
    "map" => <<-MAP
      function(doc) {
        if(doc.email && doc.token) {
          emit(doc.token, doc);
        }
      }
    MAP
  }
}

begin
  document = @db.get("_design/user")
  if document["views"] != user_views
    document["views"] = user_views
    @db.save_doc(document)
  end
rescue RestClient::ResourceNotFound
  @db.save_doc({
    "_id" => "_design/user",
    views: user_views
  })
end
