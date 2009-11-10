module PersistenceCouchDB
  module Comment

    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def comment_by_id(id)
        props = PersistenceCouchDB::Setup.db.get(id)
        c = ::Comment.new
        c.properties = props
        c
      end

      def do_paginate(items_per_page, this_page, conditions)
        res = Persistence::Setup.db.view('application/relation_post_comments', :startkey => [conditions[:post_id]], :limit => items_per_page, :skip => (items_per_page * this_page))
        total = res["total_rows"]
        vals = res["rows"].map{|c| nc = ::Comment.new; nc.properties = c; c}
        return (total.to_f/items_per_page.to_f).ceil, vals
      end
    end

    module InstanceMethods
      def relation_post_comments(args)
        vals = Persistence::Setup.db.view('application/relation_post_comments', :startkey => [@properties['_id']])["rows"].map{|r| r["value"]}
        vals.map{|d| b = ::Comment.new; b.properties = d; b}
      end
    end

  end
end
