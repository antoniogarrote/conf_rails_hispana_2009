require 'digest'

class User < Persistence::Base

  # RedisRecord relations
  if defined?(RedisRecord) && ancestors.include?(RedisRecord::Model)
    has_many :blogs, :posts, :comments
  end

  def self.create!(properties)
    @user = User.new
    properties.each_pair{ |k,v| @user.set(k,v)}

    @user.set(:password_hash,Digest::MD5.hexdigest(@user.get(:password)))

    @user.set(:created_at, DateTime.now.to_s)
    @user.create!

    @user
  end

end
