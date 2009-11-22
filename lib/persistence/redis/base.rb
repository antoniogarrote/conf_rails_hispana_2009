require 'digest'
require 'redisrecord'

module PersistenceRedis
  class Base < RedisRecord::Model

    include PersistenceRedis::User
    include PersistenceRedis::Session
    include PersistenceRedis::Blog
    include PersistenceRedis::Post
    include PersistenceRedis::Comment

    attr_accessor :properties

    # public API

    # Retrieves the value of a property for a certain set of
    # values stored in the backend with the same identity.
    # This function *doesn't* fetch the property against from the backend.
    # It retrieves the value from the local memory.
    def get(property)
      self.send(property.to_sym)
    end

    # Sets the value of one of the properties retrieved
    # from the backend for a certain group of properties
    # with the same identity.
    # This function *doesn't* update the value of the property
    # in the backend. It only updates the local memory.
    def set(property, value)
      self.send("#{property}=".to_sym, value)
    end

    # Retrieves again the values of a certain group of properties
    # with the same identity from the backend and store them in
    # the local memory.
    # Old values stored in local memory are overwritten.
    #def reload; end

    # Changes the values of a certain group of properties with
    # the same identity in the remote backend.
    # It uses the values stored in local memory to update remote
    # values.
    # On error, it must throw an exception.
    def update!
      self.save
    end

    # It creates a new remote set of properties with
    # the provided values and the same associated
    # identity in the remote backend.
    # On error, it must throw an exception.
    def create!
      self.save
      self.set_lookup(:login) if self.is_a?(User)
      :ok
    end

    # It destroys the set of properties and values
    # stored in the remote backend that have the
    # same identity than local properties and
    # values.
    # On error it will throw and exception.
    # Local memory must be invalidated and any
    # further tries of accessing its values must
    # throw an exception.
    def destroy!
      self.destroy
    end

    # It retrieves a sets of properties from the remote
    # backend grouped by identity using the semantics
    # passed as arguments in the 'finder' parameter
    # and the values passed in the 'arguments' parameter.
    class << self
      alias :rr_find :find
    end

    def self.find(*args)
      if args.length == 1
        return rr_find(args[0]) # forward to RedisRecord
      else
        case args[0].to_s
          when /^by_/
            lookup = args[0].to_s.gsub(/^by_/, '')
            case lookup
              when 'id'
                return rr_find(args[1]) # forward to RedisRecord
              else
                return self.send("find_by_#{lookup}", args[1])
            end
          else
            finder_method = "#{self.name.downcase}_#{argv[0]}"
            return self.send(finder_method, argv[1])
        end
      end
    end

    # It retrieves the set of properties of the identities
    # or identity associate to this one by the relation
    # 'related' and arguments 'arguments'
    def relation(related, arguments=[])
      self.send(related.to_sym)
    end

  end
end
