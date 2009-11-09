require 'digest'

class Blog < AgnosticObject

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
