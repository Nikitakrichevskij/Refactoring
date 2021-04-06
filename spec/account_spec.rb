RSpec.describe Account do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze
  COMMON_PHRASES = {
    create_first_account: "There is no active accounts, do you want to be the first?[y/n]\n",
    destroy_account: "Are you sure you want to destroy account?[y/n]\n",
    if_you_want_to_delete: 'If you want to delete:',
    choose_card: 'Choose the card for putting:',
    choose_card_withdrawing: 'Choose the card for withdrawing:',
    input_amount: 'Input the amount of money',
    withdraw_amount: 'Input the amount of money'
  }.freeze

  HELLO_PHRASES = [
    'Hello, we are RubyG bank!',
    '- If you want to create account - press `create`',
    '- If you want to load account - press `load`',
    '- If you want to exit - press `exit`'
  ].freeze

  ASK_PHRASES = {
    name: 'Enter your name',
    login: 'Enter your login',
    password: 'Enter your password',
    age: 'Enter your age'
  }.freeze

  # rubocop:disable Metrics/LineLength

  CREATE_CARD_PHRASES = [
    'You could create one of 3 card types',
    '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`',
    '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`',
    '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`',
    '- For exit - press `exit`'
  ].freeze

  # rubocop:enable Metrics/LineLength

  ACCOUNT_VALIDATION_PHRASES = {
    name: {
      first_letter: 'Your name must not be empty and starts with first upcase letter'
    },
    login: {
      present: 'Login must be longer then 4 symbols. Login must be shorter then 20 symbols',
      longer: 'Login must be longer then 4 symbols. Login must be shorter then 20 symbols',
      shorter: 'Login must be longer then 4 symbols. Login must be shorter then 20 symbols',
      exists: 'Login must be longer then 4 symbols. Login must be shorter then 20 symbols'
    },
    password: {
      present: 'Password must be longer then 6 symbols. Password must be shorter then 30 symbols',
      longer: 'Password must be longer then 6 symbols. Password must be shorter then 30 symbols',
      shorter: 'Password must be longer then 6 symbols. Password must be shorter then 30 symbols'
    },
    age: {
      length: 'Your Age must be greeter then 23 and lower then 90'
    }
  }.freeze

  ERROR_PHRASES = {
    user_not_exists: 'Cant find account with this login',
    wrong_command: 'Wrong command. Try again!',
    no_active_cards: "There is no active cards!\n",
    wrong_card_type: "Wrong card type. Try again!\n",
    wrong_number: "You entered wrong number!\n",
    correct_amount: 'You must input correct amount of money',
    tax_higher: 'Your tax is higher than input amount'
  }.freeze

  MAIN_OPERATIONS_TEXTS = [
    'If you want to:',
    '- show all cards - press SC',
    '- create card - press CC',
    '- destroy card - press DC',
    '- put money on card - press PM',
    '- withdraw money on card - press WM',
    '- send money to another card  - press SM',
    '- destroy account - press `DA`',
    '- exit from account - press `exit`'
  ].freeze

  CARDS = {
    usual: {
      type: 'usual',
      balance: 50.00
    },
    capitalist: {
      type: 'capitalist',
      balance: 100.00
    },
    virtual: {
      type: 'virtual',
      balance: 150.00
    }
  }.freeze

  subject(:current_subject) { described_class.new }

  let(:test_file) { 'account.yml' }
  let(:directory_path) { 'BankStorage::STORAGE_DIRECTORY' }
  let(:filename) { 'BankStorage::STORAGE_FILE' }
  let(:db_test) { 'spec/fixtures' }

  describe '#console' do
    context 'when correct method calling' do
      after do
        current_subject.start
      end

      it 'create account if input is create' do
        allow(current_subject.communication).to receive(:start_menu).and_return('create')
        expect(current_subject).to receive(:create)
      end

      it 'load account if input is load' do
        allow(current_subject.communication).to receive(:start_menu).and_return('load')
        expect(current_subject).to receive(:loading)
      end

      it 'leave app if input is exit or some another word' do
        allow(current_subject.communication).to receive(:start_menu).and_return('exit')
        expect(current_subject).to receive(:exit_command)
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }

    before do
      allow(current_subject.communication).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
      Dir.mkdir(db_test)
    end

    after do
      File.delete(File.join(db_test, test_file))
      Dir.rmdir(db_test)
    end

    context 'with success result' do
      it 'write to file User_data instance' do
        allow(current_subject).to receive(:main_menu)
        current_subject.create
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = current_subject.store.data[:user]
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a(UserData) }
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(current_subject.communication).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([])
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:name][:first_letter] }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:present] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:longer] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:shorter] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:exists] }

          before do
            allow(current_subject).to receive(:accounts) { [instance_double('Account', login: error_input)] }
          end

          it do
            expect { current_subject.create }.to output(/#{error}/).to_stdout
          end
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { ACCOUNT_VALIDATION_PHRASES[:age][:length] }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:present] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:longer] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:shorter] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      before do
        stub_const(directory_path, db_test)
        stub_const(filename, test_file)
        allow(current_subject.communication).to receive(:login_search).with(current_subject.accounts)
        allow(current_subject.communication).to receive(:password_search).with(current_subject.accounts)
      end

      it do
        allow(current_subject.communication).to receive(:main_menu)
        current_subject.loading
        expect(current_subject.store.data[:user]).to eq([])
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(current_subject.communication).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:accounts) { [instance_double('Account', login: login, password: password)] }
      end

      context 'with active accounts' do
        context 'with correct outout' do
          let(:all_inputs) { [login, password] }

          it do
            expect(current_subject).to receive(:main_menu)
            [ASK_PHRASES[:login], ASK_PHRASES[:password]].each do |phrase|
              expect(current_subject.communication.view).to receive(:puts).with(phrase)
            end
            current_subject.loading
          end
        end

        context 'when account exists' do
          let(:all_inputs) { [login, password] }

          it do
            expect(current_subject).to receive(:main_menu)
            expect { current_subject.loading }.not_to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
          end
        end

        context 'when account doesn\t exists' do
          let(:all_inputs) { ['test', 'test', login, password] }

          it do
            expect(current_subject).to receive(:main_menu)
            expect { current_subject.loading }.to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
          end
        end
      end
    end
  end

  describe '#main_menu' do
    let(:commands) do
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card,
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money,
        'DA' => :destroy_account
      }
    end

    context 'with correct outout' do
      it do
        allow(current_subject.functions).to receive(:show_cards)
        allow(current_subject).to receive(:exit)
        allow(current_subject.communication).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        MAIN_OPERATIONS_TEXTS.each do |text|
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
          expect { current_subject.main_menu }.to output(/#{text}/).to_stdout
        end
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        commands.each do |command, method|
          allow(current_subject.communication).to receive(:main_menu).and_return(command)
          expect(current_subject.functions).to receive(method)
          current_subject.main_menu
        end
      end

      it 'calls exit command' do
        allow(current_subject.communication).to receive(:main_menu).and_return('exit')
        expect(current_subject).to receive(:exit_command)
        current_subject.main_menu
      end

      it 'outputs incorrect message on undefined command' do
        expect(current_subject).to receive(:exit)
        allow(current_subject.communication).to receive_message_chain(:gets, :chomp).and_return(undefined_command,
                                                                                                'exit')
        expect { current_subject.main_menu }.to output(/#{ERROR_PHRASES[:wrong_command]}/).to_stdout
      end
    end
  end

  describe '#show_cards' do
    context 'When cards exist' do
      subject(:card_functions) { CardFunctions.new(current_acc, true, true) }

      let(:cards) { CardUsual.new }
      let(:current_acc) { UserData.new(name: 'Johnny', age: '29', login: 'login', password: 'password', card: [cards]) }

      it 'display cards if there are any' do
        expect(card_functions).to receive(:puts)
        card_functions.show_cards
      end
    end

    context 'When cards arent exist' do
      subject(:card_functions) { CardFunctions.new(current_acc_without_cards, true, true) }

      let(:current_acc_without_cards) do
        UserData.new(name: 'Johnny', age: '29', login: 'login', password: 'password', card: [])
      end

      it 'display cards if there are any' do
        expect(card_functions.communication.view).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
        card_functions.show_cards
      end
    end
  end

  describe '#create_card' do
    subject(:card_functions) { CardFunctions.new(current_acc, storage, true) }

    before do
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
      storage.data[:user] << current_acc
    end

    after do
      File.delete(File.join(db_test, test_file))
      Dir.rmdir(db_test)
    end

    let(:storage) { BankStorage.new }
    let(:current_acc) { UserData.new(name: 'Johnny', age: '29', login: 'login', password: 'password', card: []) }

    CARDS = {
      usual: {
        type: 'usual',
        balance: 50.00
      },
      capitalist: {
        type: 'capitalist',
        balance: 100.00
      },
      virtual: {
        type: 'virtual',
        balance: 150.00
      }
    }.freeze
    CARDS.each do |card_type, card_info|
      it "create card with #{card_type} type" do
        expect(card_functions.communication).to receive(:card_init).and_return(card_info[:type])
        card_functions.create_card
        file_accounts = storage.data[:user]
        expect(file_accounts.first.card.first.type).to eq card_info[:type]
        expect(file_accounts.first.card.first.balance).to eq card_info[:balance]
        expect(file_accounts.first.card.first.number.length).to be 16
      end
    end
  end

  describe '#destroy_card' do
    before do
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
    end

    after do
      File.delete(File.join(db_test, test_file))
      Dir.rmdir(db_test)
    end

    context 'without cards' do
      subject(:card_functions) { CardFunctions.new(without_card_data, storage, true) }

      let(:without_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [])
      end
      let(:storage) { BankStorage.new }

      it 'shows message about not active cards' do
        expect(card_functions.communication.view).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
        card_functions.destroy_card
      end
    end
  end

  context 'with cards' do
    subject(:card_functions) { CardFunctions.new(with_card_data, storage, true) }

    let(:with_card_data) do
      UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: fake_cards)
    end
    let(:storage) { BankStorage.new }
    let(:card_one) { CardVirtual.new }
    let(:card_two) { CardUsual.new }
    let(:fake_cards) { [card_one, card_two] }

    it 'delete card' do
      allow(card_functions.communication).to receive(:serial_number_of_card).and_return('1')
      card_functions.destroy_card
      expect(card_functions.current_account.card).not_to include(card_one)
    end

    context 'with correct outout' do
      it do
        fake_cards.each_with_index do |card, i|
          allow(card_functions.communication).to receive(:serial_number_of_card).and_return(i + 1)
          message = /If you want to delete #{card.number}, #{card.type}, press #{i + 1}/
          expect { card_functions.destroy_card }.to output(message).to_stdout
        end
        card_functions.destroy_card
      end
    end

    context 'with incorrect input of card number' do
      it do
        allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('6', '1')
        expect { card_functions.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
      end

      it do
        allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('-5', '1')
        expect { card_functions.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
      end
    end
  end

  describe 'put_money' do
    before do
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
    end

    after do
      File.delete(File.join(db_test, test_file))
      Dir.rmdir(db_test)
    end

    let(:storage) { BankStorage.new }

    context 'without cards' do
      subject(:card_functions) { CardFunctions.new(without_card_data, storage, true) }

      let(:without_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [])
      end
      let(:storage) { BankStorage.new }

      it 'with correct outout' do
        expect(card_functions.communication.view).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
        card_functions.put_money
      end
    end

    context 'with cards' do
      subject(:card_functions) { CardFunctions.new(with_card_data, storage, true) }

      let(:card_one) { CardVirtual.new }
      let(:card_two) { CardVirtual.new }
      let(:fake_cards) { [card_one, card_two] }
      let(:with_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: fake_cards)
      end

      context 'with correct outout' do
        it do
          fake_cards.each_with_index do |card, i|
            allow(card_functions.communication).to receive(:serial_number_of_card).and_return(i + 1)
            allow(card_functions.communication).to receive(:money_amount).and_return(900)
            message = /Choose the card for putting: #{card.number}, #{card.type}, press #{i + 1}/
            expect { card_functions.put_money }.to output(message).to_stdout
          end
        end
      end

      context 'with incorrect input of card number' do
        it do
          allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('6', '1')
          expect { card_functions.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('-5', '1')
          expect { card_functions.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        context 'with correct output' do
          let(:card_number) { 1 }
          let(:money_amont) { 200 }

          it do
            allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(card_number,
                                                                                                   money_amont)
            expect { card_functions.put_money }.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
          end

          it 'put money on card' do
            allow(card_functions.communication).to receive(:serial_number_of_card).and_return(card_number)
            allow(card_functions.communication).to receive(:money_amount).and_return(money_amont)
            card_functions.put_money
            expect(card_functions.current_account.card[0].balance).to be > 200
          end
        end
        
      end
    end
  end

  describe '#withdraw_money' do
    before do
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
    end

    after do
      File.delete(File.join(db_test, test_file))
      Dir.rmdir(db_test)
    end

    let(:card_one) { CardUsual.new }
    let(:card_two) { CardVirtual.new }
    let(:fake_cards) { [card_one, card_two] }
    let(:storage) { BankStorage.new }

    context 'without cards' do
      subject(:card_functions) { CardFunctions.new(without_card_data, storage, true) }

      let(:without_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [])
      end

      it 'shows message about not active cards' do
        expect(card_functions.communication.view).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
        card_functions.withdraw_money
      end

      context 'with cards' do
        subject(:card_functions) { CardFunctions.new(with_card_data, storage, true) }

        let(:with_card_data) do
          UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: fake_cards)
        end
        
        context 'with correct outout' do
          it do
            fake_cards.each_with_index do |card, i|
              allow(card_functions.communication).to receive(:serial_number_of_card).and_return(i + 1)
              allow(card_functions.communication).to receive(:money_amount).and_return(900)
              message = /Choose the card for withdrawing: #{card.number}, #{card.type}, press #{i + 1}/
              expect { card_functions.withdraw_money }.to output(message).to_stdout
            end
          end
        end
        
        context 'with incorrect input of card number' do
          it do
            allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('6', '1')
            expect { card_functions.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
          end
  
          it do
            allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('-5', '1')
            expect { card_functions.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
          end
        end
        
        context 'with correct input of card number' do
          let(:card_number) { 1 }
          let(:money_amont) { 200 }
          it do
            allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(card_number,
                                                                                                   money_amont)
            expect { card_functions.put_money }.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
          end

        it 'withdraw money' do
          allow(card_functions.communication).to receive(:serial_number_of_card).and_return(1)
          allow(card_functions.communication).to receive(:money_amount).and_return(10)
          card_functions.withdraw_money
          expect(card_functions.current_account.card[0].balance).to be < 50
        end
      end
    end
    end
  end

  describe 'communications' do
    subject(:communication) { Communication.new }

    context 'start_menu input' do
      let(:correct_comand) { 'create' }
      let(:incorrect_comand) { 'eww' }

      before do
        allow(communication.output).to receive(:welcome)
      end


    
    end

    context 'name_init input' do
      let(:correct_input) { 'Nikita' }

      it 'test correct name input' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.name_init).to eq(correct_input)
      end

      it 'test name with small first letter' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return(correct_input.downcase, correct_input)
        expect(communication.name_init).to eq(correct_input)
      end

      it 'test short name input' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return('e', correct_input)
        expect(communication.name_init).to eq(correct_input)
      end

      it 'test long name input' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return('qwdqwdqqdqwqwqwdqwqwde', correct_input)
        expect(communication.name_init).to eq(correct_input)
      end
    end

    context 'age_init input' do
      let(:correct_input) { '28' }

      it 'test correct age input' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.age_init).to eq(correct_input)
      end

      it 'test age < 23 ' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return('1', correct_input)
        expect(communication.age_init).to eq(correct_input)
      end

      it 'test age > 90' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return('200', correct_input)
        expect(communication.age_init).to eq(correct_input)
      end
    end

    context 'login_init input' do
      before do
        stub_const(directory_path, db_test)
        stub_const(filename, test_file)
      end

      after do
        File.delete(File.join(db_test, test_file))
        Dir.rmdir(db_test)
      end

      let(:accounts) { BankStorage.new.data[:user] }
      let(:some_account) { UserData.new(name: 'qqq', age: '29', login: 'qwerty', password: 'qwdqwdq', card: []) }
      let(:correct_input) { 'qwertyy' }
      let(:some_account) { UserData.new(name: 'qqq', age: '29', login: 'qwerty', password: 'qwdqwdq', card: []) }

      it 'test correct login input during registration' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.login_init(accounts)).to eq(correct_input)
      end

      it 'test login input wich already exsist during registration' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return('qwerty', correct_input)
        expect(communication.login_init(accounts)).to eq(correct_input)
      end

      it 'test login input < 4' do
        allow(communication).to receive(:gets).and_return('qwe', correct_input)
        expect(communication.login_init(accounts)).to eq(correct_input)
      end

      it 'test login input > 20' do
        allow(communication).to receive(:gets).and_return((21.times { 'k' }).to_s, correct_input)
        expect(communication.login_init(accounts)).to eq(correct_input)
      end
    end

    context 'password init ' do
      let(:correct_input) { 'nikitysik))' }

      it 'test correct login input during registration' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.password_init).to eq(correct_input)
      end

      it 'test password input < 6' do
        allow(communication).to receive(:gets).and_return('qwe', correct_input)
        expect(communication.password_init).to eq(correct_input)
      end

      it 'test login input > 30' do
        allow(communication).to receive(:gets).and_return((30.times { 'k' }).to_s, correct_input)
        expect(communication.password_init).to eq(correct_input)
      end
    end

    context 'login_search input' do
      before do
        stub_const(directory_path, db_test)
        stub_const(filename, test_file)
      end

      after do
        File.delete(File.join(db_test, test_file))
        Dir.rmdir(db_test)
      end

      let(:accounts) { BankStorage.new.data[:user] }
      let(:correct_input) { 'qwertyy' }
      let(:some_account) do
        UserData.new(name: 'qqq', age: '29', login: correct_input, password: correct_input, card: [])
      end

      it 'test coorect login input ' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.login_search(accounts)).to eq(correct_input)
      end

      it 'test incorrect login input ' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return('q', correct_input)
        expect(communication.login_search(accounts)).to eq(correct_input)
      end
    end

    context 'password_search input' do
      before do
        stub_const(directory_path, db_test)
        stub_const(filename, test_file)
        communication.instance_variable_set(:@login, 'qwerty')
      end

      after do
        File.delete(File.join(db_test, test_file))
        Dir.rmdir(db_test)
      end

      let(:accounts) { BankStorage.new.data[:user] }
      let(:correct_input) { 'qwertyy' }
      let(:some_account) { UserData.new(name: 'qqq', age: '29', login: 'qwerty', password: correct_input, card: []) }

      it 'test coorect password input ' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.password_search(accounts)).to eq(correct_input)
      end

      it 'test incorrect login input ' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return('q', correct_input)
        expect(communication.password_search(accounts)).to eq(correct_input)
      end
    end

    context 'serial_number_of_card input' do
      let(:correct_input) { '1' }
      let(:card) { CardGenerator.new }
      let(:some_account) { UserData.new(name: 'qqq', age: '29', login: 'qwerty', password: 'wwwww', card: [card]) }

     

    
    end

    context 'type of card input' do
      let(:correct_input) { 'usual' }

    

      it 'test incorrect type input ' do
        allow(communication).to receive(:gets).and_return('2', correct_input)
        expect(communication.card_init).to eq(correct_input)
      end
    end

    context 'main menu input' do
      let(:correct_input) { 'SC' }

      it 'test correct command input ' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.main_menu).to eq(correct_input)
      end

      it 'test incorrect command input ' do
        allow(communication).to receive(:gets).and_return('2', correct_input)
        expect(communication.main_menu).to eq(correct_input)
      end
    end
  end
end
