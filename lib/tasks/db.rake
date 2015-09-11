require 'fileutils'

desc "Clear all magazines from resource db/magazines"
namespace :db do
  task :clear do
    FileUtils.rm Dir['db/magazines/*.yml']
  end
end
