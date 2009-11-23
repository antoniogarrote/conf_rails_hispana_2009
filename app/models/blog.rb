require 'digest'

class Blog < Persistence::Base

  # RedisRecord relations
  if defined?(RedisRecord) && ancestors.include?(RedisRecord::Model)
    belongs_to :user
    has_many :posts
  end

  def self.create!(properties)

    raise Exception.new(":user_id is mandatory") if properties[:user_id].nil?
    raise Exception.new(":title is mandatory") if properties[:title].nil?


    @blog = Blog.new
    properties.each_pair{ |k,v| @blog.set(k,v)}

    time = DateTime.now.to_s
    @blog.set(:created_at, time)
    @blog.set(:updated_at, time)

    @blog.create!

    @blog
  end
end
