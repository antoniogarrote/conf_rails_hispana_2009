desc "creates the persistence layer for the application"
namespace :persistence do
  task :create_layer => :environment do
    Persistence::Setup.create!
  end
end
