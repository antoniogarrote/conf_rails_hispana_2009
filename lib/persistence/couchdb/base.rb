require 'digest'

module PersistenceCouchDB
  class Base

    RETRIES = 50

    include PersistenceCouchDB::User
    include PersistenceCouchDB::Session
    include PersistenceCouchDB::Blog
    include PersistenceCouchDB::Post

    attr_accessor :properties

    # public API

    # Retrieves the value of a property for a certain set of
    # values stored in the backend with the same identity.
    # This function *doesn't* fetch the property again from the backend.
    # It retrieves the value from the local memory.
    def get(property)
      property = property.to_s
      property = "_id" if property == "id"
      property = "_rev" if property == "rev"
      @properties[property]
    end

    # Sets the value of one of the properties retrieved
    # from the backend for a certain group of properties
    # with the same identity.
    # This function *doesn't* update the value of the property
    # in the backend. It only updates the local memory.
    def set(property, value)
      property = property.to_s
      @properties[property] = value
    end

    # Retrieves again the values of a certain group of properties
    # with the same identity from the backend and store them in
    # the local memory.
    # Old values stored in local memory are overwritten.
    def reload!
      @properties = Persistence::Setup.db.get(@properties['_id'])
    end

    # Changes the values of a certain group of properties with
    # the same identity in the remote backend.
    # It uses the values stored in local memory to update remote
    # values.
    # On error, it must throw an exception.
    def update!
      saved = false
      retries = RETRIES
      while !saved
        begin
          res = Persistence::Setup.db.save_doc(@properties)
          @properties = Persistence::Setup.db.get(res['id'])
          saved = true
        rescue Exception => ex
          raise ex if ex.http_code != 409
          if(retries > 0)
            @new_properties = Persistence::Setup.db.get(@properties['_id'])
            @properties.each_pair do |k,v|
              if k != "_rev" && k != "_id"
                @new_properties[k] = v
              end
            end
            @properties = @new_properties
          else
            raise ex
          end
        end
      end
      :ok
    end

    # It creates a new remote set of properties with
    # the provided values and the same associated
    # identity in the remote backend.
    # On error, it must throw an exception.
    def create!
      @properties[:type] = @model
      gen_id!
      res = Persistence::Setup.db.save_doc(@properties)
      @properties = Persistence::Setup.db.get(res['id'])
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
      Persistence::Setup.db.delete_doc(@properties)
      @properties = nil
    end

    # It retrieves a sets of properties from the remote
    # backend grouped by identity using the semantics
    # passed as arguments in the 'finder' parameter
    # and the values passed in the 'arguments' parameter.
    def self.find(finder, arguments)
      finder_method = "#{self.to_s.downcase}_#{finder}".to_sym
      self.send(finder_method, arguments)
    end

    # It retrieves the set of properties of the identities
    # or identity associate to this one by the relation
    # 'related' and arguments 'arguments'
    def relation(related, arguments=[])
      relation_method = "relation_#{self.class.to_s.downcase}_#{related}".to_sym
      self.send(relation_method, arguments)
    end


    # particular functions


    def initialize
      @model = self.class.to_s.downcase
      @properties = { }
    end

    def gen_id!
      if @model == "user"
        @properties['_id'] = Digest::MD5.hexdigest(@properties["login"])
      elsif @model == "blog"
        @properties['_id'] = beautify(@properties['title'])
      elsif @model == "post"
        @properties['_id'] = beautify(@properties['title'])
      end
    end

    private
    def beautify str
      str.gsub(' ', '-').gsub(/[^a-zA-Z0-9\_\-\.]/, '')
    end

  end
end
