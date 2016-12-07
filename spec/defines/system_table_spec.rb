require 'spec_helper'

describe 'incron::system_table' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'should fail if path and command and custom_content are undef' do
          let(:title) { 'foobar' }
          it {
            expect {
              is_expected.to compile.with_all_deps
            }.to raise_error(/You must specify either/)
          }
        end

        context 'with path only' do
          let(:title) { 'path_test' }
          let(:params) {{
            :path => '/some/valid/path',
          }}
          let(:expected) { "/some/valid/path IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE \n" }
          it { is_expected.to create_file('/etc/incron.d/path_test').with_content(expected) }
        end

        context 'with command only' do
          let(:title) { 'command_test' }
          let(:params) {{
            :command => '/some/valid/command',
          }}
          let(:expected) { " IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE /some/valid/command\n" }
          it { is_expected.to create_file('/etc/incron.d/command_test').with_content(expected) }
        end

        context 'with custom_content only' do
          let(:title) { 'custom_content_test' }
          let(:params) {{
            :custom_content => "totally valid incron content\n"
          }}
          let(:expected) { "totally valid incron content\n" }
          it { is_expected.to create_file('/etc/incron.d/custom_content_test').with_content(expected) }
        end

      end
    end
  end
end
