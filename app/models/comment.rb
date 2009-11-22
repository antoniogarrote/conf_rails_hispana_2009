class Comment < AgnosticObject

  if AgnosticObject.superclass.superclass == RedisRecord::Model
    belongs_to :post
  end

  def self.create!(properties)

    raise Exception.new(":content is mandatory") if properties[:content].nil?
    raise Exception.new(":post_id is mandatory") if properties[:post_id].nil?
    raise Exception.new(":user_id is mandatory") if properties[:user_id].nil?
    raise Exception.new(":user_name is mandatory") if properties[:user_name].nil?

    if properties[:user_id].nil?
      properties[:anonymous] = true
      properties[:user_name] = "anonymous"
    else
      properties[:anonymous] = false
    end

    properties[:score] = 0

    @comment = Comment.new
    properties.each_pair{ |k,v| @comment.set(k,v)}

    time = DateTime.now.to_s
    @comment.set(:created_at, time)
    @comment.set(:updated_at, time)

    @comment.create!

    @comment
  end
end
