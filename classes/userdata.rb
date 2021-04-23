# frozen_string_literal: true

class UserData
  attr_reader :name, :age, :login, :password, :index
  attr_accessor :card

  def initialize(params)
    @name = params[:name]
    @age = params[:age]
    @login = params[:login]
    @password = params[:password]
    @card = params[:card]
  end
end
