module PersistenceRedis
  module Comment

#    def self.included(base)
#      base.send(:extend, ClassMethods)
#      base.send(:include, InstanceMethods)
#    end
#
#    module ClassMethods
#      def comment_by_id(id)
#        props = PersistenceCouchDB::Setup.db.get(id)
#        c = ::Comment.new
#        c.properties = props
#        c
#      end
#    end
#
#    module InstanceMethods
#      def relation_post_comments(args)
#        vals = Persistence::Setup.db.view('application/relation_post_comments', :startkey => [@properties['_id']])["rows"].map{|r| r["value"]}
#        vals.map{|d| b = ::Comment.new; b.properties = d; b}
#      end
#    end

  end
end
