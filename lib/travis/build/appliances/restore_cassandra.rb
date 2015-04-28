require 'travis/build/appliances/base'

module Travis
  module Build
    module Appliances
      class RestoreCassandra < Base
        def apply
          sh.cmd 'sudo rm -rf /usr/local/cassandra && curl -s https://s3.amazonaws.com/travis-cassandra-archives/cassandra-2.0.9-ubuntu-12.04-x86_64.tar.gz -o - | sudo tar xzf - -C /usr/local', echo: false
        end
      end
    end
  end
end

