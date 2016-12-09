require 'spec_helper'

describe 'incron::user' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with default parameters' do
          let(:title) { 'foobar' }
          it { is_expected.to create_concat__fragment("incron_user_#{title}") }
        end

      end
    end
  end
end
