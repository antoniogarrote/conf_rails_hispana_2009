class Session < Persistence::Base
  def self.create!(properties)
    raise Exception.new("user_id is required") if properties[:user_id].nil?

    @s = Session.new
    properties.each_pair{ |k,v| @s.set(k,v)}
    @s.set(:created_at, DateTime.now.to_s)
    @s.create!

    @s
  end
end
