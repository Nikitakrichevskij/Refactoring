class UserData
  attr_reader :name, :age, :login, :password, :index
  attr_accessor :card

  def initialize(name:, age:, login:, password:, card:)
    @name = name
    @age = age
    @login = login
    @password = password
    @card = card
  end
end
