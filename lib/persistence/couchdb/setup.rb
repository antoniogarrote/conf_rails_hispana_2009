module PersistenceCouchDB
  class Setup

    # public API
    def self.boot!
      @@config = YAML.load_file(File.join(RAILS_ROOT, "config", "persistence", "couchdb.yaml"))
      @@db = CouchRest.database!("http://#{@@config[:server]}:#{@@config[:port]}/#{@@config[:database]}")
    end

    def self.create!
      # destroy and recreate the db
      self.boot!

      @@db.delete_doc db.get("_design/application") rescue nil

      @@db.save_doc({
                "_id" => "_design/application",
                "validate_doc_update" => 'function(newDoc, oldDoc, userCtx) {
                                            // save validations user
                                            if(newDoc.type == "user" && newDoc.password_hash == null) {
                                              throw {missing_field: \'User must have a hashed password.\'};
                                            }
                                            // update validations user
                                            if(newDoc.type == "user" && oldDoc != null && (newDoc.login != oldDoc.login)) {
                                              throw {missing_field: \'User login cannot be changed.\'};
                                            }
                                          }',
                :views => {
                        "relation_user_blogs" => {
                          :map => 'function(doc){
                                     if(doc.type=="blog") {
                                       emit([doc.user_id, doc.created_at], doc)
                                     }
                                   }'
                        },
                        "relation_user_posts" => {
                          :map => 'function(doc){
                                     if(doc.type=="post") {
                                       emit([doc.user_id, doc.created_at], doc)
                                     }
                                   }'
                        },
                        "relation_blog_posts" => {
                          :map => 'function(doc){
                                     if(doc.type=="post") {
                                       emit([doc.blog_id, doc.created_at], doc)
                                     }
                                   }'
                        }
                      }
              })
    end

    # particular functions

    def self.db
      @@db
    end

    def self.configuration
      @@config
    end

  end
end
