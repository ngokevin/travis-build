require 'travis/build/appliances/base'

module Travis
  module Build
    module Appliances
      class TuneGlibc < Base
        def apply
          sh.export 'MALLOC_ARENA_MAX',       '2',      echo: false
          sh.export 'MALLOC_MMAP_THRESHOLD_', '131072', echo: false
          sh.export 'MALLOC_MMAP_MAX_',       '131072', echo: false
          sh.export 'MALLOC_TOP_PAD_',        '131072', echo: false
          sh.export 'MALLOC_TRIM_THRESHOLD_', '65536',  echo: false
        end
      end
    end
  end
end