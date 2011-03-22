require 'account'
require 'utils'

module Awsam
  module Accounts

    @@accounts = {}

    def self.load!
      accts = Hash.new
      accts_dir = Awsam::get_accts_dir
      Utils::confdir_scan(accts_dir) do |name|
        acct = Account::load_from_disk(File.join(accts_dir, name))
        accts[name] = acct if acct
      end

      @@accounts = accts
    end

    def self.active
      active = ENV['AWSAM_ACTIVE_ACCOUNT']
      return nil unless active

      acct = find(active)
      unless acct
        puts "No account named '#{active}' found."
        return nil
      end

      acct
    end

    def self.get
      return @@accounts
    end

    def self.find(name)
      @@accounts[name]
    end
  end
end
