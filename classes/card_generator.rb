class CardGenerator
  attr_reader :type, :number
  attr_accessor :balance

  def cards(type)
    case type
    when 'usual' then usual
    when 'capitalist' then capitalist
    when 'virtual' then virtual
    end
  end

  def usual
    @type = 'usual'
    @number = number_generate
    @balance = 50.00
    self
  end

  def capitalist
    @type = 'capitalist'
    @number = number_generate
    @balance = 100.00
    self
  end

  def virtual
    @type = 'virtual'
    @number = number_generate
    @balance = 150.00
    self
  end

  private

  def number_generate
    16.times.map { rand(10) }.join
  end
end
