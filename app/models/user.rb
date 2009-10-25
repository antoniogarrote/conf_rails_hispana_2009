require 'digest'

class User < AgnosticObject

  agnostic_accessor :login
  agnostic_accessor :password_hash
  agnostic_accessor :email
  agnostic_accessor :name

  def self.create!(properties)
    @user = User.new
    properties.each_pair{ |k,v| @user.set(k,v)}

    @user.set(:password_hash,Digest::MD5.hexdigest(@user.get(:password)))

    @user.set(:created_at, DateTime.now.to_s)
    @user.create!

    @user
  end

end
