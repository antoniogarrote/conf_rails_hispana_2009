module PersistenceCassandra
  module Post

    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def post_by_id(id)
        p = ::Post.new
        p.properties = PersistenceCassandra::Setup.db.get(p.column_family, id)
        p
      end
    end
    
    module InstanceMethods
      def relation_post_comments(args)
        commentslist = PersistenceCassandra::Setup.db.get(:CommentsforPost, self.get("id"))
        comments=[]
        commentslist.each_pair do |date, id|
          p = ::Comment.new
          p.properties = PersistenceCassandra::Setup.db.get(:Comment, id)
          comments << p
        end
        comments
      end
    end
    
  end
end
