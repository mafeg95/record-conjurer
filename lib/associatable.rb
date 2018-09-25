require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name.downcase}_id".to_sym
    @class_name = options[:class_name] || name.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    @class_name = options[:class_name] || name.camelcase.singularize
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name.to_s, options)
    assoc_options[name.to_sym] = options
    define_method(name) do
      val = send(options.foreign_key)
      options.model_class.where(options.primary_key => val).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name.to_s, self.name, options)
    define_method(name) do
      val = send(options.primary_key)
      options.model_class.where(options.foreign_key => val)
    end
  end

  def assoc_options
    @assoc_options_hash ||= {}
  end
end

class SQLObject
  extend Associatable
end