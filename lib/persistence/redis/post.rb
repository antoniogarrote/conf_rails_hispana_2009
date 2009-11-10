module PersistenceCouchDB
  module Post

    def self.included(base)
      base.send(:extend, ClassMethods)
      #base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def post_by_id(id)
        props = PersistenceCouchDB::Setup.db.get(id)
        p = ::Post.new
        p.properties = props
        p
      end
    end
  end
end
