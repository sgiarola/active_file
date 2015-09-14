require 'fileutils'

namespace :db do

  desc "Clear all products from resource db/folder"
  task :clear, [:folder] do |task, args|
    FileUtils.rm Dir["db/#{args.folder}/*.yml"]
  end

  desc "Seed products in resource db/folder"
  task :seed, [:folder] do
    seed_file = File.expand_path "db/#{args.folder}/seeds.rb"
    load(seed_file) if File.exists?(seed_file)

  desc "Reseed products in resource db/folder"
  task :reseed, [:folder] => ["db:clear", "db:seed"] do
  end
end
