# frozen_string_literal: true

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # サポートモジュールのインクルード
  config.include UserSupport,    type: :system
  config.include BookSupport,    type: :system
  config.include OtherSupport,   type: :system
  config.include CommentSupport, type: :system
  config.include ContactSupport, type: :system
  config.include Warden::Test::Helpers

  # FactoryBotのメソッドを簡略化して使えるようにする
  config.include FactoryBot::Syntax::Methods
  # Request Specでsign_in等を使えるようにする
  config.include Devise::Test::IntegrationHelpers, type: :request

  # System Specのドライバ設定（画面あり Chrome）
  config.before(:each, type: :system) do
    driven_by :selenium_chrome do |driver_option|
      driver_option.add_argument('--window-size=1280,1024')
    end
  end

  # --- DatabaseCleaner の設定 ---
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :system) do
    # System Specはトランザクションが効かないため truncation を使用
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Warden.test_reset!
    ActionMailer::Base.deliveries.clear
  end
  # ----------------------------

  # Rails標準のフィクスチャトランザクションは使用せず、DatabaseCleanerに委ねる
  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

# Omniauthのモック設定
OmniAuth.config.test_mode = true