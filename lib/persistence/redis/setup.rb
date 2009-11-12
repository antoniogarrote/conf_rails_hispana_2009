module PersistenceRedis
  class Setup

    # public API
    def self.boot!
      @@logger = Logger.new(STDOUT)
      @@logger.level = Logger::DEBUG

      @@config = YAML.load_file(File.join(RAILS_ROOT, "config", "persistence", "redis.yaml"))
      @@db = Redis.new(:host => @@config[:host], 
                       :port => @@config[:port], 
                       :db => @@config[:database],
                       :logger => @@logger
                      )

      @@db.flush_db if RAILS_ENV =~ /development/
    end

    def self.create!
      # destroy and recreate the db
      self.boot!

      @@db.flush_db
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
