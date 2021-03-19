class BankStorage
  STORAGE_DIRECTORY = 'db'.freeze
  STORAGE_FILE = 'db.yml'.freeze
  attr_accessor :data

  def initialize
    @data = db_initialized? ? load : initialize_db
  end

  def save
    store = YAML::Store.new(storage_path)
    store.transaction { @data.each { |key, value| store[key] = value } }
  end

  private

  def db_initialized?
    Dir.exist?(STORAGE_DIRECTORY) && File.file?(File.join(STORAGE_DIRECTORY, STORAGE_FILE))
  end

  def initialize_db
    Dir.mkdir(STORAGE_DIRECTORY)

    store = YAML::Store.new(File.join(STORAGE_DIRECTORY, STORAGE_FILE))
    store.transaction { default_data.each { |key, value| store[key] = value } }

    default_data
  end

  def default_data
    {
      user: []
    }
  end

  def storage_path
    File.join(STORAGE_DIRECTORY, STORAGE_FILE)
  end

  def load
    store = YAML::Store.new(storage_path)
    store.transaction { store.roots.to_h { |key| [key, store[key]] } }
  end
end
