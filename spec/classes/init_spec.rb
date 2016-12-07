require 'spec_helper'

describe 'incron' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('incron') }
          it { is_expected.to create_incron__user('root') }
          it { is_expected.to create_simpcat_build('incron') }
          it { is_expected.to create_file('/etc/incron.deny').with({:ensure => 'absent'}) }
          it { is_expected.to create_package('incron').with({:ensure => 'latest'}) }
          it { is_expected.to create_service('incrond').with({
            :ensure     => 'running',
            :enable     => true,
            :hasstatus  => true,
            :hasrestart => true
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

      end
    end
  end
end
