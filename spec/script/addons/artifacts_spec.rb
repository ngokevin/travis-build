require 'ostruct'
require 'spec_helper'

describe Travis::Build::Script::Addons::Artifacts do
  let(:script) { stub_everything('script') }
  let(:data) do
    OpenStruct.new.tap do |o|
      o.pull_request = false
      o.branch = 'master'
      o.slug = 'hamster/wheel'
      o.build = { number: '123' }
      o.job = { number: '123.1' }
    end
  end

  before(:each) { script.stubs(:fold).yields(script) }
  before(:each) { script.stubs(:data).returns(data) }

  subject { described_class.new(script, config) }

  context 'with a config' do
    let(:config) do
      {
        key: 'AZ1234',
        secret: 'BX12345678',
        bucket: 'hambone',
        private: true,
        max_size: 100 * 1024 * 1024,
        concurrency: 1000,
        target_paths: [
          'artifacts/$(go env GOOS)/$(go env GOARCH)/$TRAVIS_REPO_SLUG/' \
            '$TRAVIS_BUILD_NUMBER/$TRAVIS_JOB_NUMBER'
        ]
      }
    end

    it 'exports ARTIFACTS_BUCKET' do
      script.expects(:set).with('ARTIFACTS_BUCKET', 'hambone', echo: false,
                                assert: false)
      subject.after_script
    end

    it 'exports ARTIFACTS_PRIVATE' do
      script.expects(:set).with('ARTIFACTS_PRIVATE', 'true', echo: false,
                                assert: false)
      subject.after_script
    end

    it 'overrides ARTIFACTS_TARGET_PATHS' do
      script.expects(:set).with('ARTIFACTS_TARGET_PATHS', 'hamster/wheel/123/123.1', echo: false, assert: false)
      subject.after_script
    end

    it 'overrides ARTIFACTS_CONCURRENCY' do
      script.expects(:set).with(
        'ARTIFACTS_CONCURRENCY', "#{subject.send(:concurrency)}",
        echo: false, assert: false
      )
      subject.after_script
    end

    it 'overrides ARTIFACTS_MAX_SIZE' do
      script.expects(:set).with(
        'ARTIFACTS_MAX_SIZE', "#{subject.send(:max_size)}",
        echo: false, assert: false
      )
      subject.after_script
    end

    it 'defaults ARTIFACTS_PATHS' do
      script.expects(:set).with('ARTIFACTS_PATHS', '$(git ls-files -o | tr "\n" ";")', echo: true, assert: false)
      subject.after_script
    end

    it 'defaults ARTIFACTS_LOG_FORMAT' do
      script.expects(:set).with('ARTIFACTS_LOG_FORMAT', 'multiline', echo: false, assert: false)
      subject.after_script
    end

    it 'installs artifacts' do
      script.expects(:cmd).with(subject.send(:install_script), echo: false, assert: false).once
      subject.after_script
    end

    it 'prefixes $PATH with $HOME/bin' do
      script.expects(:set).with('PATH', '$HOME/bin:$PATH', echo: false, assert: false).once
      subject.after_script
    end

    it 'runs the command' do
      script.expects(:cmd).with('artifacts upload ', assert: false).once
      subject.after_script
    end

    it 'overwrites :concurrency' do
      script.expects(:set).with('ARTIFACTS_CONCURRENCY', '5', echo: false, assert: false).once
      subject.after_script
    end

    it 'overwrites :max_size' do
      script.expects(:set).with('ARTIFACTS_MAX_SIZE', "#{Float(5 * 1024 * 1024)}", echo: false, assert: false).once
      subject.after_script
    end
  end

  context 'with an invalid config' do
    let(:config) do
      {
        private: true,
        target_paths: [
          'artifacts/$(go env GOOS)/$(go env GOARCH)/$TRAVIS_REPO_SLUG/' \
            '$TRAVIS_BUILD_NUMBER/$TRAVIS_JOB_NUMBER',
          'artifacts/$(go env GOOS)/$(go env GOARCH)/$TRAVIS_REPO_SLUG/' \
            '$TRAVIS_COMMIT'
        ]
      }
    end

    it 'echoes a message about missing :key' do
      script.expects(:cmd).with('echo "Artifacts config missing :key param"', echo: false, assert: false).once
      subject.after_script
    end

    it 'echoes a message about missing :secret' do
      script.expects(:cmd).with('echo "Artifacts config missing :secret param"', echo: false, assert: false).once
      subject.after_script
    end

    it 'echoes a message about missing :bucket' do
      script.expects(:cmd).with('echo "Artifacts config missing :bucket param"', echo: false, assert: false).once
      subject.after_script
    end

    it 'aborts before running anything' do
      subject.expects(:install).never
      subject.expects(:configure_env).never
      subject.after_script
    end
  end

  context 'without a config' do
    let(:config) { {} }

    it "doesn't do anything" do
      script.expects(:set).never
      script.expects(:cmd).never
      script.expects(:fold).never
      subject.after_script
    end
  end

  context 'when not runnable' do
    let(:config) do
      {
        key: 'AZ1234',
        secret: 'BX12345678',
        bucket: 'hambone'
      }
    end

    before(:each) { subject.stubs(:runnable?).returns(false) }

    it 'echoes that artifacts are disabled for pull requests and nothing else' do
      script.expects(:cmd).with('echo "\nArtifacts support disabled for pull requests"', echo: false, assert: false).once
      script.expects(:set).never
      script.expects(:fold).never
      subject.after_script
    end

    it 'echoes that artifacts are disabled for the current branch and nothing else' do
      script.expects(:cmd).with(%Q{echo "Artifacts support disabled for branch \"#{subject.send(:branch)}\""}, echo: false, assert: false).once
      script.expects(:set).never
      script.expects(:fold).never
      subject.after_script
    end
  end
end
