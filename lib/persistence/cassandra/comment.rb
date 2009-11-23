module PersistenceCassandra
  module Comment

    def self.included(base)
      base.send(:extend, ClassMethods)
      #base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def comment_by_id(id)
        c = ::Comment.new
        c.properties = Persistence::Setup.db.get(c.column_family, id)
        c
      end

      def do_paginate(items_per_page, this_page, conditions)
        raise "sin terminar do paginate"
        # Persistence::Setup.db.get(:CommentsforPost, id)
        # 
        # res = Persistence::Setup.db.view('application/relation_post_comments', :startkey => [conditions[:post_id]], :limit => items_per_page, :skip => (items_per_page * this_page))
        # total = res["total_rows"]
        # vals = res["rows"].map{|c| nc = ::Comment.new; nc.properties = c; c}
        # return (total.to_f/items_per_page.to_f).ceil, vals
      end
    end

  end
end
