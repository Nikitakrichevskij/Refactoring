# frozen_string_literal: true

class WrongSerial < StandardError
  def initialize
    super(I18n.t(:wrong_serial))
  end
end
