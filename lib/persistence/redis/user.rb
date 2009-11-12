require 'digest'

module PersistenceRedis
  module User

    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def user_by_login(login)
        #arguments = Digest::MD5.hexdigest(login)
        return self.new(Marshal.load(PersistenceRedis::Setup.db.get("#{self.name}:#{login}")))
      end

#      def user_by_id(id)
#        u = ::User.new
#        u.properties = Marshal.load(PersistenceRedis::Setup.db.get("#{@model}:#{id}"))
#        u
#      end
    end

    module InstanceMethods
      def relation_user_blogs(args)
        ids = Persistence::Setup.db.list_range("User:#{@properties[:id]}:blogs", 0, -1)
        ids.map {|id| Blog.find(:by_id, id)}
        #vals = Persistence::Setup.db.view('application/relation_user_blogs', :startkey => [@properties['_id']])["rows"].map{|r| r["value"]}
        #vals.map{|d| b = ::Blog.new; b.properties = d; b}
      end
    end

  end
end
