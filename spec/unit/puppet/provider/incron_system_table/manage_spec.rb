require 'spec_helper'

describe Puppet::Type.type(:incron_system_table).provider(:manage) do
  let(:provider) {
    Puppet::Type.type(:incron_system_table).provider(:manage).new(resource)
  }

  context 'working examples' do
    before(:each) do
      @tmpdir = Dir.mktmpdir('incron_system_table')

      # Set up some glob search scaffolding
      FileUtils.mkdir_p(File.join(@tmpdir, 'this', 'is', '1', 'test'))
      FileUtils.mkdir_p(File.join(@tmpdir, 'that', 'is', '2', 'test'))
      FileUtils.mkdir_p(File.join(@tmpdir, 'other', 'is', '3', 'test'))

      File.stubs(:read).with('/etc/incron.conf').
        returns("system_table_dir = #{@tmpdir}")
    end

    after(:each) do
      FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)
    end

    let(:resource_name) { 'foo' }
    let(:path)          { '/foo/bar' }
    let(:mask)          { 'IN_CREATE' }
    let(:command)       { '/bin/true' }

    let(:resource) {
      Puppet::Type.type(:incron_system_table).new(
        name: resource_name,
        path: path,
        mask: mask,
        command: command
      )
    }

    let(:resource_output) { "#{path} #{Array(mask).join(',')} #{command}" }

    let(:target) { File.join(@tmpdir, resource_name) }

    context '#exists?' do
      it 'does not exist' do
        expect(provider.exists?).to be false
      end

      context 'does exist' do
        context 'does match' do
          it do
            File.stubs(:readable?).with(File.join(@tmpdir, resource_name)).returns(true)
            File.stubs(:read).with(File.join(@tmpdir, resource_name)).
              returns("#{path} #{mask} #{command}")

            expect(provider.exists?).to be true
          end
        end

        context 'is not readable' do
          it do
            File.stubs(:readable?).with(File.join(@tmpdir, resource_name)).returns(false)

            expect(provider.exists?).to be false
          end
        end

        context 'does not match' do
          it do
            File.stubs(:readable?).with(File.join(@tmpdir, resource_name)).returns(true)
            File.stubs(:read).with(File.join(@tmpdir, resource_name)).
              returns("#{path} #{mask} #{command} and stuff")

            expect(provider.exists?).to be false
          end
        end
      end
    end

    context '#create' do
      before(:each) do
        # This needs to be called to populate the instance variables
        provider.exists?
      end

      it do
        expect{provider.create}.to_not raise_error
        expect(File.readable?(target)).to be true

        # Work around the stubs with IO
        expect(IO.read(target).strip).to eq(resource_output)
      end

      context 'with a path glob' do
        let(:path) { File.join(@tmpdir, '**', 'is', '*') }
        let(:resource_output){
          [
            File.join(@tmpdir, 'other', 'is', '3') + " #{mask} #{command}",
            File.join(@tmpdir, 'this', 'is', '1') + " #{mask} #{command}",
            File.join(@tmpdir, 'that', 'is', '2') + " #{mask} #{command}",
          ].sort.join("\n")
        }

        it do
          expect{provider.create}.to_not raise_error
          expect(IO.read(target).lines.sort.join.strip).to eq(resource_output)
        end
      end

      context 'with a multi-part mask' do
        let(:mask) { ['IN_CREATE', 'IN_NO_LOOP'] }

        it do
          expect{provider.create}.to_not raise_error
          expect(IO.read(target).strip).to eq(resource_output)
        end

        context 'with a multi-part path' do
          let(:path) { ['/foo/bar', '/foo2/bar2'] }
          let(:resource_output){
            [
              "/foo/bar #{Array(mask).join(',')} #{command}",
              "/foo2/bar2 #{Array(mask).join(',')} #{command}"
            ].join("\n")
          }

          it do
            expect{provider.create}.to_not raise_error
            expect(IO.read(target).strip).to eq(resource_output)
          end

          context 'with a multi-part command' do
            let(:command) { ['/bin/cmd', '/bin/cmd2'] }
            let(:resource_output){
              [
                "/foo/bar #{Array(mask).join(',')} /bin/cmd",
                "/foo/bar #{Array(mask).join(',')} /bin/cmd2",
                "/foo2/bar2 #{Array(mask).join(',')} /bin/cmd",
                "/foo2/bar2 #{Array(mask).join(',')} /bin/cmd2"
              ].join("\n")
            }

            it do
              expect{provider.create}.to_not raise_error
              expect(IO.read(target).strip).to eq(resource_output)
            end
          end
        end
      end
    end
  end
end
