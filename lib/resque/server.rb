require 'resque/server'

module Resque
  class Server
    helpers do
      def ensure_authenticated
        unless env['warden'].authenticate!
          throw(:warden)
        end
      end
    end

    before do
      ensure_authenticated
    end
  end
end
