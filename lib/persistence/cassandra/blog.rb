module PersistenceCassandra
  module Blog

    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def blog_by_id(id)
        b = ::Blog.new
        b.properties = PersistenceCassandra::Setup.db.get(b.column_family, id)
        b
      end
    end

    module InstanceMethods
      def relation_blog_posts(args)
        postlist = PersistenceCassandra::Setup.db.get(:PostsforBlog, self.get("id"))
        posts=[]
        postlist.each_pair do |date, id|
          p = ::Post.new
          p.properties = PersistenceCassandra::Setup.db.get(:Post, id)
          posts << p
        end
        posts
      end
    end

  end
end
