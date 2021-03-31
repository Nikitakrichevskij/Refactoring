class Account < Console
  attr_reader :name, :age, :login, :password, :accounts, :current_account, :functions
  attr_accessor :store

  def initialize
    super()
    @store = BankStorage.new
    @accounts = store.data[:user]
  end

  def create
    data_input
    store.data[:user] << user_data
    store.save

    @current_account = user_data
    @functions = CardFunctions.new(current_account, store, accounts)
    main_menu
  end

  def loading
    @login = communication.login_search(accounts)
    @password = communication.password_search(accounts)
    @current_account = accounts.select { |account| account.login == login }.first
    @functions = CardFunctions.new(current_account, store, accounts)
    main_menu
  end

  private

  def data_input
    @name = communication.name_init
    @age = communication.age_init
    @login = communication.login_init(accounts)
    @password = communication.password_init
  end

  def user_data
    user_data_params = {
      name: @name,
      age: @age,
      login: @login,
      password: @password,
      card: []
    }
    UserData.new(user_data_params)
  end
end
