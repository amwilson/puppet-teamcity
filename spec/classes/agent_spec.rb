require 'spec_helper'

describe 'teamcity::agent', :type => :class do
  let(:params) do
    {
      :agentname    => 'test-agent-1',
      :username     => 'teamcity',
      :server_url   => 'http://10.10.21.42',
      :archive_name => 'buildAgent.zip',
      :agent_dir    => 'build-agent',
      :priority     => '20'
    }
  end

  context 'the ordering of the module should be' do
    let(:facts) do
      {
        :osfamily => 'Debian',
        :path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :kernel   => 'Linux'
      }
    end

    it { should compile.with_all_deps }
    it { should contain_class('teamcity::user_mgmt').that_comes_before('teamcity::agent::install') }
    it { should contain_class('teamcity::agent::install').that_comes_before('teamcity::agent::config') }
    it { should contain_class('teamcity::agent::config').that_comes_before('teamcity::agent::service') }
  end

  context 'using params defaults the install class (on ubuntu)' do
    let(:facts) do
      {
        :osfamily => 'Debian',
        :kernel   => 'Linux'
      }
    end

    it { should contain_class('teamcity::agent::install') }

    it do
      should contain_package('unzip', 'default-jre') \
        .with_ensure('installed')
    end

    it do
      should contain_file('agent_home') \
        .with_ensure('directory') \
        .with_path('/home/teamcity') \
        .with_group('teamcity') \
        .with_owner('teamcity')
    end

    it do
      should contain_wget__fetch('teamcity-buildagent') \
        .with_source('http://10.10.21.42/update/buildAgent.zip') \
        .with_destination('/root/buildAgent.zip') \
        .with_timeout('0')
    end

    it do
      should contain_file('/var/tainted') \
        .with_ensure('directory')
    end

    it do
      # rubocop:disable LineLength
      should contain_exec('extract-build-agent') \
        .with_command('unzip -d /var/tainted/build-agent /root/buildAgent.zip && cp /var/tainted/build-agent/conf/buildAgent.dist.properties /var/tainted/build-agent/conf/buildAgent.properties && chown teamcity:teamcity /var/tainted/build-agent -R') \
        .with_path('/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin') \
        .with_creates('/var/tainted/build-agent') \
        .with_logoutput('on_failure')
      # rubocop:enable LineLength
    end

    it do
      should contain_file('/var/tainted/build-agent/bin/') \
        .with_mode('0755') \
        .with_recurse('true')
    end
  end

  context 'using params defaults the config class (on ubuntu)' do
    let(:facts) do
      {
        :osfamily => 'Debian',
        :kernel   => 'Linux'
      }
    end

    it { should contain_class('teamcity::agent::config') }

    it do
      should contain_exec('Ensure buildAgent.properties exists on ubuntu') \
        .with_command('cp buildAgent.dist.properties buildAgent.properties') \
        .with_onlyif('test -e /var/tainted/build-agent/conf/buildAgent.properties') \
        .with_cwd('/var/tainted/build-agent/conf')
    end

    it do
      should contain_ini_setting('server url') \
        .with_ensure('present') \
        .with_section('') \
        .with_key_val_separator('=') \
        .with_setting('serverUrl') \
        .with_value('http://10.10.21.42') \
        .with_path('/var/tainted/conf/buildAgent.properties')
    end

    it do
      should contain_ini_setting('agent name') \
        .with_ensure('present') \
        .with_section('') \
        .with_key_val_separator('=') \
        .with_setting('name') \
        .with_value('test-agent-1') \
        .with_path('/var/tainted/conf/buildAgent.properties')
    end
  end

  context 'using params defaults the config class (on windows)' do
    let(:facts) do
      {
        :osfamily => 'Windows'
      }
    end

    it { should contain_class('teamcity::agent::config') }

    it do
      should contain_exec('Ensure buildAgent.properties exists on windows') \
        .with_command('cp buildAgent.dist.properties buildAgent.properties') \
        .with_onlyif('if(Test-Path c:/buildAgent/conf/buildAgent.properties) { exit 1 } else { exit 0 }') \
        .with_cwd('c:/buildAgent/conf')
    end

    it do
      should contain_ini_setting('server url') \
        .with_ensure('present') \
        .with_section('') \
        .with_key_val_separator('=') \
        .with_setting('serverUrl') \
        .with_value('http://10.10.21.42') \
        .with_path('c:/buildAgent/conf/buildAgent.properties')
    end

    it do
      should contain_ini_setting('agent name') \
        .with_ensure('present') \
        .with_section('') \
        .with_key_val_separator('=') \
        .with_setting('name') \
        .with_value('test-agent-1') \
        .with_path('c:/buildAgent/conf/buildAgent.properties')
    end
  end

  context 'using params defaults the service class (on ubuntu)' do
    let(:facts) do
      {
        :osfamily => 'Debian',
        :kernel   => 'Linux'
      }
    end

    it { should contain_class('teamcity::agent::service') }

    it do
      should contain_service('build-agent') \
        .with_enable('true') \
        .with_ensure('running') \
        .with_hasstatus('false')
    end
  end

  context 'using params defaults the service class (on windows)' do
    let(:facts) do
      {
        :osfamily => 'Windows'
      }
    end

    it { should contain_class('teamcity::agent::service') }
    it { should contain_service('TCBuildAgent').with_ensure('running') }
  end
end
