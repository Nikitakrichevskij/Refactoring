class WrongCommand < StandardError
  ERROR_MESSAGE = I18n.t(:wrong_command)

  def initialize
    super(ERROR_MESSAGE)
  end
end
