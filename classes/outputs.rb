class Outputs
  def output(message = nil)
    return yield if block_given?

    puts I18n.t(message)
  end
end
