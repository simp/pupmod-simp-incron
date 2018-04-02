require 'spec_helper_acceptance'

test_name 'at'

describe 'incron class' do
  let(:manifest) {
    <<-EOS
      package { 'epel-release':
        ensure => installed,
        before => Class['incron']
      }
      include 'incron'
    EOS
  }

  context 'on each host' do
    hosts.each do |host|
      it 'should work with default values' do
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end
    end
  end
end
