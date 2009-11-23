require 'digest'

module PersistenceCassandra
  module Session
    def self.included(base)
      base.send(:extend, ClassMethods)
      #base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def session_by_id(id)
        s = ::Session.new
        s.properties = PersistenceCassandra::Setup.db.get(s.column_family, id)
        s
      end
    end
  end
end
