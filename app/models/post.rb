require 'digest'

class Post < AgnosticObject

  def self.create!(properties)

    raise Exception.new(":user_id is mandatory") if properties[:user_id].nil?
    raise Exception.new(":blog_id is mandatory") if properties[:blog_id].nil?
    raise Exception.new(":title is mandatory") if properties[:title].nil?
    raise Exception.new(":title is mandatory") if properties[:content].nil?

    @post = Post.new
    properties.each_pair{ |k,v| @post.set(k,v)}

    time = DateTime.now.to_s
    @post.set(:created_at, time)
    @post.set(:updated_at, time)

    @post.create!

    @post
  end
end
