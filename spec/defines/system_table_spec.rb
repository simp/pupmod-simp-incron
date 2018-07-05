require 'spec_helper'

describe 'incron::system_table' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with path and command only' do
          let(:title) { 'path_and_command_test' }
          let(:params) {{
            :path => '/some/valid/path',
            :command => '/some/valid/command',
          }}

          it { is_expected.to create_incron_system_table('path_and_command_test') }
        end

        context 'with custom_content only' do
          let(:title) { 'custom_content_test' }
          let(:params) {{
            :custom_content => "totally valid incron content\n"
          }}

          it { is_expected.to create_incron_system_table('custom_content_test') }
        end
      end
    end
  end
end
