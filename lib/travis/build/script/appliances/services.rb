require 'shellwords'

module Travis
  module Build
    class Script
      module Appliances
        class Services < Base
          SERVICES = {
            'hbase'        => 'hbase-master', # for HBase status, see travis-ci/travis-cookbooks#40. MK.
            'memcache'     => 'memcached',
            'neo4j-server' => 'neo4j',
            'rabbitmq'     => 'rabbitmq-server',
            'redis'        => 'redis-server'
          }

          def apply
            services.each do |name|
              sh.cmd "sudo service #{name.shellescape} start", assert: false
            end
            sh.raw 'sleep 3'
          end

          def apply?
            services.any?
          end

          private

            def services
              @services ||= Array(config).map { |name| normalize(name) }
            end

            def normalize(name)
              name = name.to_s.downcase
              SERVICES[name] ? SERVICES[name] : name
            end
        end
      end
    end
  end
end