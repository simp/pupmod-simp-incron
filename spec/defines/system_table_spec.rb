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
            path: '/some/valid/path',
            command: '/some/valid/command',
          }}
          let(:expected) { "/some/valid/path IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE /some/valid/command\n" }
          it { is_expected.to create_file('/etc/incron.d/path_and_command_test').with_content(expected) }
        end

        context 'with custom_content only' do
          let(:title) { 'custom_content_test' }
          let(:params) {{
            custom_content: "totally valid incron content\n"
          }}
          let(:expected) { "totally valid incron content\n" }
          it { is_expected.to create_file('/etc/incron.d/custom_content_test').with_content(expected) }
        end

      end
    end
  end
end
