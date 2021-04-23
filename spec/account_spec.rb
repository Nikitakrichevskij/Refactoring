RSpec.describe Account do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze
  COMMON_PHRASES = {
    create_first_account: "There is no active accounts, do you want to be the first?[y/n]\n",
    destroy_account: "Are you sure you want to destroy account?[y/n]\n",
    if_you_want_to_delete: 'If you want to delete:',
    choose_card: 'Choose the card for putting:',
    choose_card_withdrawing: 'Choose the card for withdrawing:',
    input_amount: 'Input the amount of money you want to put on your card',
    withdraw_amount: 'Input the amount of money you want to withdraw'
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
    login: 'Login must present, be longer then 4 symbols and shorter then 20 symbols or such account is already exists',
    password: 'Password must present, be longer then 6 symbols and shorter then 30 symbols',
    age: {
      length: 'Your Age must be greeter then 23 and lower then 90'
    }
  }.freeze

  ERROR_PHRASES = {
    user_not_exists: 'There is no account with given credentials',
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

  let(:directory_path) { 'BankStorage::STORAGE_DIRECTORY' }
  let(:app_path) { 'BankStorage::STORAGE_FILE' }
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
      stub_const(app_path, OVERRIDABLE_FILENAME)
      Dir.mkdir(db_test)
    end

    after do
      File.delete(OVERRIDABLE_FILENAME)
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
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login] }

          before do
            allow(current_subject).to receive(:accounts) { [instance_double('Account', login: error_input)] }
          end

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
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
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      before do
        stub_const(directory_path, db_test)
        stub_const(app_path, OVERRIDABLE_FILENAME)
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

    context 'When there are no active cards' do
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
      stub_const(app_path, OVERRIDABLE_FILENAME)
      storage.data[:user] << current_acc
    end

    after do
      File.delete(OVERRIDABLE_FILENAME)
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
      stub_const(app_path, OVERRIDABLE_FILENAME)
    end

    after do
      File.delete(OVERRIDABLE_FILENAME)
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

    context 'when exit if first gets is exit' do
      it do
        expect(card_functions.communication).to receive_message_chain(:gets, :chomp) { 'exit' }
        card_functions.destroy_card
      end
    end

    context 'with correct outout' do
      it do
        fake_cards.each_with_index do |card, i|
          allow(card_functions.communication).to receive(:serial_number_of_card).and_return(i + 1)
          allow(card_functions.communication).to receive(:card_delete_confirmation)
          message = /If you want to delete #{card.number}, #{card.type}, press #{i + 1}/
          expect { card_functions.destroy_card }.to output(message).to_stdout
        end
        card_functions.destroy_card
      end
    end

    context 'with incorrect input of card number' do
      it do
        allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('6', 'exit')
        expect { card_functions.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
      end

      it do
        allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('-5', 'exit')
        expect { card_functions.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
      end
    end

    context 'with correct input of card number' do
      let(:accept_for_deleting) { 'y' }
      let(:reject_for_deleting) { 'asdf' }
      let(:deletable_card_number) { 1 }

      it 'accept deleting' do
        commands = [deletable_card_number, accept_for_deleting]
        allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(*commands)
        expect { card_functions.destroy_card }.to change { card_functions.current_account.card.size }.by(-1)
      end

      it 'decline deleting' do
        commands = [deletable_card_number, reject_for_deleting]
        allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(*commands)
        expect { card_functions.destroy_card }.not_to change { card_functions.current_account.card.size }
      end
    end
  end

  describe 'put_money' do
    before do
      stub_const(directory_path, db_test)
      stub_const(app_path, OVERRIDABLE_FILENAME)
    end

    after do
      File.delete(OVERRIDABLE_FILENAME)
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
          allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('6', 'exit')
          expect { card_functions.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return('-5', 'exit')
          expect { card_functions.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { CardCapitalist.new }
        let(:card_two) { CardCapitalist.new }
        let(:fake_cards) { [card_one, card_two] }
        let(:with_card_data) do
          UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: fake_cards)
        end

        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 100.0 }
        let(:correct_money_amount) { 30 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, correct_money_amount] }

          it do
            expect { card_functions.put_money }.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
          end

          context 'with amount lower then 0' do
            let(:commands) { [chosen_card_number, incorrect_money_amount, chosen_card_number, correct_money_amount] }

            it do
              expect { card_functions.put_money }.to output(/#{ERROR_PHRASES[:correct_amount]}/).to_stdout
            end
          end

          context 'with amount greater then 0' do
            context 'with tax greater than amount' do
              let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

              it do
                expect { card_functions.put_money }.to output(/#{ERROR_PHRASES[:tax_higher]}/).to_stdout
              end
            end
          end

          context 'with tax lower than amount' do
            let(:with_card_data) do
              UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: custom_cards)
            end

            let(:custom_cards) { [CardUsual.new, CardCapitalist.new, CardVirtual.new] }

            it do
              custom_cards.each_with_index do |custom_card, index|
                custom_card.instance_variable_set(:@balance, default_balance)
                allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(index + 1,
                                                                                                       correct_money_amount_greater_than_tax)
                new_balance = default_balance + correct_money_amount_greater_than_tax - custom_card.put_tax(correct_money_amount_greater_than_tax)

                expect { card_functions.put_money }.to output(
                  /Money #{correct_money_amount_greater_than_tax} was put on #{custom_card.number}. Balance: #{new_balance}. Tax: #{custom_card.put_tax(correct_money_amount_greater_than_tax)}/
                ).to_stdout

                expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
                storage.data[:user] << with_card_data

                file_accounts = storage.data[:user]
                expect(file_accounts.first.card[index].balance).to eq(new_balance)
              end
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    before do
      stub_const(directory_path, db_test)
      stub_const(app_path, OVERRIDABLE_FILENAME)
    end

    after do
      File.delete(OVERRIDABLE_FILENAME)
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
            allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(
              fake_cards.length + 1, 'exit'
            )
            expect { card_functions.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
          end

          it do
            allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(- 1, 'exit')
            expect { card_functions.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
          end
        end

        context 'with correct input of card number' do
          let(:card_one) { CardCapitalist.new }
          let(:card_two) { CardCapitalist.new }
          let(:fake_cards) { [card_one, card_two] }
          let(:with_card_data) do
            UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: fake_cards)
          end

          let(:chosen_card_number) { 1 }
          let(:incorrect_money_amount) { -2 }
          let(:default_balance) { 50.0 }
          let(:correct_money_amount) { 30 }
          let(:correct_money_amount_lower_than_tax) { 5 }
          let(:correct_money_amount_greater_than_tax) { 50 }

          before do
            allow(card_functions.communication).to receive_message_chain(:gets, :chomp).and_return(*commands)
          end

          context 'with correct output' do
            let(:commands) { [chosen_card_number, correct_money_amount] }

            it do
              expect { card_functions.put_money }.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
            end
          end
        end
      end
    end
  end
end
