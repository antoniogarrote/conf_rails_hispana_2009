module PersistenceCassandra
  class Setup

    # public API
    def self.boot!
      @@config = YAML.load_file(File.join(RAILS_ROOT, "config", "persistence", "cassandra.yaml"))
      @@db =  Cassandra.new(@@config[:keyspace], "%s:%s" % [@@config[:host].to_s, @@config[:port].to_s], :retries => @@config[:retries])
    end

    def self.create!
      # destroy and recreate the db
      self.boot!
      @@db.clear_keyspace!
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
