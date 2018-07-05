require 'spec_helper_acceptance'

test_name 'incron'

describe 'incron class' do
  let(:test_file_content) {
    'this is a test'
  }

  let(:test_target) { '/tmp/test_output' }

  let(:test_script) {[
   %(#!/bin/sh),
   %(echo $1 > #{test_target})
  ].join("\n")}

  let(:test_script_path) { '/root/test.sh' }

  hosts.each do |host|
    context "on #{host}" do
      let(:manifest) {
        <<-EOS
          incron::system_table { 'puppet_test':
            path    => "#{host.puppet[:environmentpath]}/*/modules/*/lib",
            command => "#{test_script_path} $@/$#"
          }
        EOS
      }
      let(:test_file) {
        "#{host.puppet[:environmentpath]}/production/modules/incron/lib/test"
      }

      it 'should work with default values' do
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'should have a test script to run' do
        create_remote_file(host, test_script_path, test_script)
        on(host, "chmod 755 #{test_script_path}")
      end

      it 'should create a file that triggers incron' do
        create_remote_file(host, test_file, test_file_content)
      end

      it 'should have a report' do
        expect(host.file_exist?(test_target)).to be true

        content = on(host,"cat #{test_target}").stdout.strip
        expect(content).to eq test_file
      end
    end
  end
end
