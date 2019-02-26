require 'spec_helper'
require 'open3'

describe 'incrond_version' do

  before :each do
    Facter.clear
  end

  context 'incrond command exists' do
    it 'returns the correct version of incrond when incrond is executable' do
      Facter::Util::Resolution.expects(:which).with('incrond').returns('/usr/sbin/incrond')
      File.expects(:executable?).with('/usr/sbin/incrond').returns(true)
      # 3rd entry in returned array is a ProcessStatus object, but since we don't
      # use it, not mocking its value
      Open3.expects(:capture3).with('/usr/sbin/incrond', '--version').returns(['', "incrond 1.2.3\n", nil])
      expect(Facter.fact(:incrond_version).value).to eq('1.2.3')
    end

    it 'returns nil when incrond is not executable' do
      Facter::Util::Resolution.expects(:which).with('incrond').returns('/usr/sbin/incrond')
      File.expects(:executable?).with('/usr/sbin/incrond').returns(false)
      expect(Facter.fact(:incrond_version).value).to eq(nil)
    end
  end

  context 'incrond command does not exist' do
    it 'returns nil' do
      Facter::Util::Resolution.expects(:which).with('incrond').returns(nil)
      expect(Facter.fact(:incrond_version).value).to eq(nil)
    end
  end
end
