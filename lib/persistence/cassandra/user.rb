require 'digest'

module PersistenceCassandra
  module User

    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def user_by_login(login)
        u = ::User.new
        u.properties = PersistenceCassandra::Setup.db.get(u.column_family, login)
        u.properties["id"] = login
        u
      end

      def user_by_id(id)
        user_by_login(id)
      end
    end

    module InstanceMethods
      def relation_user_blogs(args)
        bloglist = PersistenceCassandra::Setup.db.get(:BlogsforUser, self.get("id"))
        blogs=[]
        bloglist.each_pair do |date, id|
          b = ::Blog.new
          b.properties = PersistenceCassandra::Setup.db.get(:Blog, id)
          blogs << b
        end
        blogs
      end
    end

  end
end