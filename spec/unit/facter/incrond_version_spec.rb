require 'spec_helper'
require 'open3'

describe 'incrond_version' do
  before :each do
    Facter.clear
  end

  context 'incrond command exists' do
    it 'returns the correct version of incrond when incrond is executable' do
      allow(Facter::Util::Resolution).to receive(:which).with('incrond').and_return('/usr/sbin/incrond')
      allow(File).to receive(:executable?).with('/usr/sbin/incrond').and_return(true)
      # 3rd entry in returned array is a ProcessStatus object, but since we don't
      # use it, not mocking its value
      allow(Open3).to receive(:capture3).with('/usr/sbin/incrond', '--version').and_return(['', "incrond 1.2.3\n", nil])
      expect(Facter.fact(:incrond_version).value).to eq('1.2.3')
    end

    it 'returns nil when incrond is not executable' do
      allow(Facter::Util::Resolution).to receive(:which).with('incrond').and_return('/usr/sbin/incrond')
      allow(File).to receive(:executable?).with('/usr/sbin/incrond').and_return(false)
      expect(Facter.fact(:incrond_version).value).to eq(nil)
    end
  end

  context 'incrond command does not exist' do
    it 'returns nil' do
      allow(Facter::Util::Resolution).to receive(:which).with('incrond').and_return(nil)
      expect(Facter.fact(:incrond_version).value).to eq(nil)
    end
  end
end
