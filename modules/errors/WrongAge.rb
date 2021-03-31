class WrongAge < StandardError
  ERROR_MESSAGE = I18n.t(:wrong_age)
  def initialize
    super(ERROR_MESSAGE)
  end
end
