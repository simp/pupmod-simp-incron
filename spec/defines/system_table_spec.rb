# frozen_string_literal: true

require 'spec_helper'

describe 'incron::system_table' do
  context 'with supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with path and command only' do
          let(:title) { 'path_and_command_test' }
          let(:params) do
            {
              path: '/some/valid/path',
              command: '/some/valid/command'
            }
          end

          it { is_expected.to create_file("/etc/incron.d/#{title}").with_ensure('file') }
          it { is_expected.to create_incron_system_table(title) }
        end

        context 'with custom_content only' do
          let(:title) { 'custom_content_test' }
          let(:params) do
            {
              custom_content: "totally valid incron content\n"
            }
          end

          it { is_expected.to create_file("/etc/incron.d/#{title}").with_ensure('file') }
          it { is_expected.to create_incron_system_table(title) }
        end
      end
    end
  end
end
