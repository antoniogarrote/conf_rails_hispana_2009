module PersistenceRedis
  module Blog

#    def self.included(base)
#      base.send(:extend, ClassMethods)
#      base.send(:include, InstanceMethods)
#    end
#
#    module ClassMethods
#      def blog_by_id(id)
#        props = PersistenceCouchDB::Setup.db.get(id)
#        b = ::Blog.new
#        b.properties = props
#        b
#      end
#    end
#
#    module InstanceMethods
#      def relation_blog_posts(args)
#        vals = Persistence::Setup.db.view('application/relation_blog_posts', :startkey => [@properties['_id']])["rows"].map{|r| r["value"]}
#        vals.map{|d| b = ::Post.new; b.properties = d; b}
#      end
#    end

  end
end
