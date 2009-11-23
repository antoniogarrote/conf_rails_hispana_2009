require 'digest'

class String
  include Cassandra::Constants
  def to_uuidtime
    UUID.new(Time.parse(self))
  end
end

module PersistenceCassandra
  
  class Base

    include PersistenceCassandra::User
    include PersistenceCassandra::Session
    include PersistenceCassandra::Blog
    include PersistenceCassandra::Post
    include PersistenceCassandra::Comment
    include Cassandra::Constants

    attr_accessor :properties

    # public API

    # Retrieves the value of a property for a certain set of
    # values stored in the backend with the same identity.
    # This function *doesn't* fetch the property again from the backend.
    # It retrieves the value from the local memory.
    def get(property)
      @properties[property.to_s]
    end

    # Sets the value of one of the properties retrieved
    # from the backend for a certain group of properties
    # with the same identity.
    # This function *doesn't* update the value of the property
    # in the backend. It only updates the local memory.
    def set(property, value)
      @properties[property.to_s] = value
    end

    # Retrieves again the values of a certain group of properties
    # with the same identity from the backend and store them in
    # the local memory.
    # Old values stored in local memory are overwritten.
    def reload!
      @properties = Persistence::Setup.db.get(column_family, @properties['id'])
    end

    # Changes the values of a certain group of properties with
    # the same identity in the remote backend.
    # It uses the values stored in local memory to update remote
    # values.
    # On error, it must throw an exception.
    def update!
        begin
          Persistence::Setup.db.insert(column_family,@properties['id'], @properties)
        rescue Exception
          raise
        end
        :ok
    end

    # It creates a new remote set of properties with
    # the provided values and the same associated
    # identity in the remote backend.
    # On error, it must throw an exception.
    def create!
      gen_id!
      Persistence::Setup.db.insert(column_family, @properties['id'], @properties)
      if @model == "blog"
        new_blog = { @properties['created_at'].to_uuidtime => @properties['id'] }
        Persistence::Setup.db.insert(:BlogsforUser, @properties['user_id'], new_blog)
      elsif @model == "post"
        new_post = { @properties['created_at'].to_uuidtime => @properties['id'] }
        Persistence::Setup.db.insert(:PostsforBlog, @properties['blog_id'], new_post)
      end
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
      if @model == "blog"
        Persistence::Setup.db.remove(:BlogsforUser, @properties['user_id'], @properties['created_at'].to_uuidtime)
      elsif @model == "post"
        Persistence::Setup.db.remove(:PostsforBlog, @properties['blog_id'], @properties['created_at'].to_uuidtime)
      end
      Persistence::Setup.db.remove(column_family, @properties["id"])
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

    # It accepts an this_page page number, a number of items per page
    # and a hash of conditions.
    # It must returns tuple with two components the number
    # of pages, and the items in this_page.
    def self.paginate(items_per_page, this_page, conditions)
      #self.send(:do_paginate, [items_per_page,this_page, conditions])
      do_paginate(items_per_page, this_page, conditions)
    end

    # particular functions


    def initialize
      @model = self.class.to_s.downcase
      @properties = { }
    end

    def gen_id!
      if @model == "user"
        @properties['id'] = @properties['login']
      elsif @model == "blog"
        @properties['id'] = beautify(@properties['title'])
      elsif @model == "post"
        @properties['id'] = beautify(@properties['title'])
      elsif @model == "session"
        @properties['id'] = @properties['user_id']+Digest::MD5.hexdigest(Time.now.to_s)
      end
    end
    
    def column_family
      self.class.to_s.to_sym
    end

    private
    def beautify str
      str.gsub(' ', '-').gsub(/[^a-zA-Z0-9\_\-\.]/, '')
    end

  end
end