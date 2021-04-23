# frozen_string_literal: true

class BankStorage
  STORAGE_DIRECTORY = 'db'
  STORAGE_FILE = 'db/db.yml'
  attr_accessor :data

  def initialize
    @data = db_initialized? ? load : initialize_db
  end

  def save
    store = YAML::Store.new(STORAGE_FILE)
    store.transaction { @data.each { |key, value| store[key] = value } }
  end

  private

  def db_initialized?
    File.file?(STORAGE_FILE)
  end

  def initialize_db
    Dir.mkdir(STORAGE_DIRECTORY)

    store = YAML::Store.new(STORAGE_FILE)
    store.transaction { default_data.each { |key, value| store[key] = value } }

    default_data
  end

  def default_data
    {
      user: []
    }
  end

  def load
    store = YAML::Store.new(STORAGE_FILE)
    store.transaction { store.roots.to_h { |key| [key, store[key]] } }
  end
end
