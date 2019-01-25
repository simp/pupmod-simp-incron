require 'spec_helper'

describe 'incron' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts){ os_facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('incron') }
        it { is_expected.to create_incron__user('root') }
        it { is_expected.to create_concat('/etc/incron.allow') }
        it { is_expected.to create_file('/etc/incron.deny').with({:ensure => 'absent'}) }
        it { is_expected.to create_package('incron').with_ensure(/0.5.\d+/) }
        it { is_expected.to create_package('incron').without_ensure('0.5.12') }
        it { is_expected.to create_init_ulimit('mod_open_files_incrond').with_value('unlimited') }
        it { is_expected.to create_service('incrond').with({
          :ensure     => 'running',
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => false
        }) }
      end

      context 'with a users parameter' do
        let(:params) {{
          :users => ['test','foo','bar']
        }}
        it { is_expected.to create_incron__user('test') }
        it { is_expected.to create_incron__user('foo') }
        it { is_expected.to create_incron__user('bar') }
      end

      context 'with a system_table parameter' do
        let(:params) {{
          :system_table => {
            :allowrw   => {:path => '/data/', :command => '/usr/bin/chmod -R 774 $@/$#', :mask => ['IN_CREATE']},
            :deletelog => {:path => '/var/run/', :command => '/usr/bin/rm /var/log/daemon.log', :mask => ['IN_DELETE']}
          }
        }}
        it { is_expected.to create_incron__system_table('allowrw') }
        it { is_expected.to create_incron__system_table('deletelog') }
      end
    end
  end
end
