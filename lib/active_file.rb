require "active_file/version"
require "brnumeros"
require "fileutils"
require "yaml"

module ActiveFile

  def save
    @new_record = false
    File.open("db/magazines/#{@id}.yml", "w") do |file|
      file.puts serialize
    end
  end

  def destroy
    unless @destroyed or @new_record
      @destroyed = true
      FileUtils.rm "db/magazines/#{@id}.yml"
    end
  end

  class Field
    attr_reader :name, :required, :default

    def initialize(name, required, default)
      @name, @required, @default = name, required, default
    end

    def to_argument
      "#{@name}: #{@default}"
    end

    def to_assign
      "@#{@name} = #{@name}"
    end
  end

  module ClassMethods

    attr_reader :fields

    def find(id)
      raise DocumentNotFound, "Arquivo db/magazines/#{id} não encontrado", caller unless File.exists?("db/magazines/#{id}.yml")
      YAML.load File.open("db/magazines/#{id}.yml", "r")
    end

    def next_id
      Dir.glob("db/magazines/*.yml").size + 1
    end

    def field(name, required: false, default: "")
      @fields ||= []
      @fields << Field.new(name, required, default)

      base.class_eval %Q$
        attr_reader :id, :destroyed, :new_record
        def initialize(#{@fields.map(&:to_argument).join(":, ")})
          @id = self.class.next_id
          @destroyed = false
          @new_record = true
          #{@fields.map(&:to_assign).join("\n")}
        end
      $
    end

    def method_missing(name, *args, &block)
      super unless name.to_s =~ /^find_by_(.*)/
      argument = args.first
      field = $1
      super if @fields.include? field

      load_all.select do |object|
        should_select? object, field, argument
      end
    end

    private

    def should_select?(object, field, argument)
      if argument.kind_of? Regexp
        object.send(field) =~ argument
      else
        object.send(field) == argument
      end
    end

    def load_all
      Dir.glob('db/magazines/*.yml').map do |file|
        deserialize file
      end
    end

    def deserialize(file)
      YAML.load File.open(file, "r")
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  private

  def serialize
    YAML.dump self
  end
end
