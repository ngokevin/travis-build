require 'travis/build/appliances/base'

module Travis
  module Build
    module Appliances
      class RestoreMaven < Base
        def apply
          sh.cmd 'curl -s https://s3.amazonaws.com/travis-maven-archives/maven-3.2.5-ubuntu-12.04-x86_64.tar.gz -o - | sudo tar xzf - -C /usr/local', echo: false
        end
      end
    end
  end
end

