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
          it { is_expected.to create_simpcat_fragment('incron+foobar.user') }
        end

      end
    end
  end
end
