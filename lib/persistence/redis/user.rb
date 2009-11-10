require 'digest'

module PersistenceCouchDB
  module User

    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def user_by_login(login)
        id = Digest::MD5.hexdigest(login)
        props = PersistenceCouchDB::Setup.db.get(id)
        u = ::User.new
        u.properties = props
        u
      end

      def user_by_id(id)
        props = PersistenceCouchDB::Setup.db.get(id)
        u = ::User.new
        u.properties = props
        u
      end
    end

    module InstanceMethods
      def relation_user_blogs(args)
        vals = Persistence::Setup.db.view('application/relation_user_blogs', :startkey => [@properties['_id']])["rows"].map{|r| r["value"]}
        vals.map{|d| b = ::Blog.new; b.properties = d; b}
      end
    end

  end
end
