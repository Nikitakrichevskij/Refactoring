# frozen_string_literal: true

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
    user = user_data
    store.data[:user] << user
    store.save

    @current_account = user
    @functions = CardFunctions.new(current_account, store, accounts)
    main_menu
  end

  def loading
    @login = communication.login_search(accounts)
    @password = communication.password_search(accounts)
    @current_account = accounts.find { |account| account.login == login }
    @functions = CardFunctions.new(current_account, store, accounts)
    main_menu
  end

  def user_data
    UserData.new(user_data_params)
  end

  def user_data_params
    {
      name: @name,
      age: @age,
      login: @login,
      password: @password,
      card: []
    }
  end

  private

  def data_input
    @name = communication.name_init
    @age = communication.age_init
    @login = communication.login_init(accounts)
    @password = communication.password_init
  end
end
