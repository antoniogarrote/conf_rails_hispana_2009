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
      
      def blog_all(args)
        bloglist = PersistenceCassandra::Setup.db.get_range(:Blog)
        blogs=[]
        bloglist.each do |id|
          b = ::Blog.new
          b.properties = PersistenceCassandra::Setup.db.get(:Blog, id)
          blogs << b
        end
        blogs
      end
    end

    module InstanceMethods
      #has_many
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
      #belongs_to
      def relation_blog_user(args)
        u = ::User.new
        u.properties = PersistenceCassandra::Setup.db.get(:User, self.get("user_id"))
        u
      end

    end

  end
end
