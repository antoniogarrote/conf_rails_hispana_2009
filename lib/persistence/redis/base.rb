require 'digest'

module PersistenceRedis
  class Base

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
      @properties[property.to_sym]
    end

    # Sets the value of one of the properties retrieved
    # from the backend for a certain group of properties
    # with the same identity.
    # This function *doesn't* update the value of the property
    # in the backend. It only updates the local memory.
    def set(property, value)
      @properties[property.to_sym] = value
    end

    # Retrieves again the values of a certain group of properties
    # with the same identity from the backend and store them in
    # the local memory.
    # Old values stored in local memory are overwritten.
    def reload!
      @properties = Persistence::Setup.db.get(object_key)
    end

    # Changes the values of a certain group of properties with
    # the same identity in the remote backend.
    # It uses the values stored in local memory to update remote
    # values.
    # On error, it must throw an exception.
    def update!
      Persistence::Setup.db.set(object_key,Marshal.dump(@properties))
      @properties = Marshal.load(Persistence::Setup.db.get(object_key))
      :ok
    end

    # It creates a new remote set of properties with
    # the provided values and the same associated
    # identity in the remote backend.
    # On error, it must throw an exception.
    def create!
      gen_id!
      Persistence::Setup.db.set(object_key,Marshal.dump(@properties))
      @properties = Marshal.load(Persistence::Setup.db.get(object_key))
      store_login_lookup if self.is_a?(User)
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
      Persistence::Setup.db.delete(object_key)
      @properties = nil
    end

    # It retrieves a sets of properties from the remote
    # backend grouped by identity using the semantics
    # passed as arguments in the 'finder' parameter
    # and the values passed in the 'arguments' parameter.
    def self.find(finder, arguments)
      case finder
        when :by_id
          return self.new(Marshal.load(PersistenceRedis::Setup.db.get("#{self.name}:#{arguments}")))
        else
          finder_method = "#{self.name.downcase}_#{finder}".to_sym
          self.send(finder_method, arguments)
      end
    end

    # It retrieves the set of properties of the identities
    # or identity associate to this one by the relation
    # 'related' and arguments 'arguments'
    def relation(related, arguments=[])
      relation_method = "relation_#{self.class.name.downcase}_#{related}".to_sym
      self.send(relation_method, arguments)
    end

    # particular functions

    def initialize(properties = nil)
      @properties = properties ? properties : {}
    end

    def gen_id!
      @properties[:id] = Persistence::Setup.db.incr("#{self.class.name}:autoincrement")
    end

    private

    def object_key
      "#{self.class.name}:#{@properties[:id]}"
    end
   
    # FIXME This is not very efficient... ITS NOT!
    def store_login_lookup
      Persistence::Setup.db.set("#{self.class.name}:#{@properties[:login]}",Marshal.dump(@properties))
    end

  end
end
