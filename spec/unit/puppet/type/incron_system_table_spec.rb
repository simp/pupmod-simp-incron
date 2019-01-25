#!/usr/bin/env rspec

require 'spec_helper'

incron_system_table_type = Puppet::Type.type(:incron_system_table)

describe incron_system_table_type do
  let(:name)    { 'foo' }
  let(:path)    { '/foo/bar' }
  let(:mask)    { 'IN_MODIFY' }
  let(:command) { '/bar/baz' }
  let(:content) { '/foo IN_MODIFY,IN_NO_LOOP /bar --option stuff' }

  context 'with valid' do
    it 'disabling of the resource' do
      resource = incron_system_table_type.new(
        :name    => name,
        :ensure => 'absent'
      )

      expect(resource[:name]).to eq(name)
    end

    it 'name and content parameters' do
      resource = incron_system_table_type.new(
        :name    => name,
        :content => content
      )

      expect(resource[:name]).to eq(name)
    end

    it 'content as an Array' do
      resource = incron_system_table_type.new(
        :name    => name,
        :content => [ content, "#{content}\n#{content}"]
      )

      expect(resource[:name]).to eq(name)
      expect(resource[:content]).to eq([content, content, content])
    end

    context 'name, path, mask, and command parameters' do
      it 'should pass' do
        resource = incron_system_table_type.new(
          :name    => name,
          :path    => path,
          :mask    => mask,
          :command => command
        )

        expect(resource[:name]).to eq(name)
        expect(resource[:path]).to eq([path])
        expect(resource[:mask]).to eq(mask)
        expect(resource[:command]).to eq([command])
      end

      context 'as an array' do
        let(:path)    { ['/foo/bar', '/foo2/bar2'] }
        let(:mask)    { ['IN_MODIFY', 'IN_CREATE'] }
        let(:command) { ['/bar/baz', '/bar2/baz2'] }

        it 'should pass' do
          resource = incron_system_table_type.new(
            :name    => name,
            :path    => path,
            :mask    => mask.join(','),
            :command => command
          )

          expect(resource[:name]).to eq(name)
          expect(resource[:path]).to eq(path)
          expect(resource[:mask]).to eq(mask.sort.join(','))
          expect(resource[:command]).to eq(command)
        end

        context 'with 0.5.12+ parameters' do
          let(:mask)    { ['IN_MODIFY', 'IN_CREATE', 'loopable=true', 'recursive=false', 'dotdirs=true'] }

          context 'on a system with no incrond_version fact' do
            it 'should strip out the new parameters' do
              Facter.stubs(:value).with(:incrond_version).returns(nil)

              resource = incron_system_table_type.new(
                :name    => name,
                :path    => path,
                :mask    => mask.join(','),
                :command => command
              )

              expect(resource[:mask]).to eq(mask.delete_if{|x| x.include?('=')}.sort.join(','))
            end
          end

          context 'on a system with an older version of incrond' do
            it 'should strip out the new parameters' do
              Facter.stubs(:value).with(:incrond_version).returns('0.5.10')

              resource = incron_system_table_type.new(
                :name    => name,
                :path    => path,
                :mask    => mask.join(','),
                :command => command
              )

              expect(resource[:mask]).to eq(mask.delete_if{|x| x.include?('=')}.sort.join(','))
            end
          end

          context 'on a system with 0.5.12' do
            it 'should retain the new parameters' do
              Facter.stubs(:value).with(:incrond_version).returns('0.5.12')

              resource = incron_system_table_type.new(
                :name    => name,
                :path    => path,
                :mask    => mask.join(','),
                :command => command
              )

              expect(resource[:mask]).to eq(mask.sort.join(','))
            end
          end

          context 'on a system with incrond newer than 0.5.12' do
            it 'should retain the new parameters' do
              Facter.stubs(:value).with(:incrond_version).returns('0.5.13')

              resource = incron_system_table_type.new(
                :name    => name,
                :path    => path,
                :mask    => mask.join(','),
                :command => command
              )

              expect(resource[:mask]).to eq(mask.sort.join(','))
            end
          end
        end
      end
    end
  end

  context 'with conflicting parameters' do
    [:path, :mask, :command].each do |param|
      context ":content and :#{param}" do
        it do
          expect{
            incron_system_table_type.new(
              :name => name,
              :content => content,
              param => self.send(param)
            )
          }.to raise_error(/You cannot specify/)
        end
      end
    end
  end

  context 'with missing' do
    context ':path' do
      it do
        expect{
          incron_system_table_type.new(
            :name    => name,
            :mask    => mask,
            :command => command
          )
        }.to raise_exception(/You must specify either/)
      end
    end

    context ':mask' do
      it do
        expect{
          incron_system_table_type.new(
            :name    => name,
            :path    => path,
            :command => command
          )
        }.to raise_exception(/You must specify either/)
      end
    end

    context ':command' do
      it do
        expect{
          incron_system_table_type.new(
            :name    => name,
            :path    => path,
            :mask    => mask
          )
        }.to raise_exception(/You must specify either/)
      end
    end

    context ':content' do
      it do
        expect{
          incron_system_table_type.new( :name => name )
        }.to raise_exception(/You must specify either/)
      end
    end
  end
end
