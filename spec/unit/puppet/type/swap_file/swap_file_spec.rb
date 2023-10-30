#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:swap_file) do
  before(:each) do
    @class = described_class
    # rubocop:disable RSpec/InstanceVariable
    @provider_class = @class.provide(:fake) { mk_resource_methods }
    @provider = @provider_class.new
    @resource = stub 'resource', resource: nil, provider: @provider

    @class.stubs(:defaultprovider).returns @provider_class
    @class.any_instance.stubs(:provider).returns @provider # rubocop:disable RSpec/AnyInstance
    # rubocop:enable RSpec/InstanceVariable
  end

  it 'has :name as its keyattribute' do
    expect(@class.key_attributes).to eq([:file]) # rubocop:disable RSpec/InstanceVariable
  end

  describe 'when validating attributes' do
    params = [
      :file,
    ]

    properties = [
      :type,
      :size,
      :used,
      :priority,
    ]

    params.each do |param|
      it "has a #{param} parameter" do
        expect(@class.attrtype(param)).to eq(:param) # rubocop:disable RSpec/InstanceVariable
      end
    end

    properties.each do |prop|
      it "has a #{prop} property" do
        expect(@class.attrtype(prop)).to eq(:property) # rubocop:disable RSpec/InstanceVariable
      end
    end

    ['.', './foo', '\\foo', 'C:/foo', '\\Server\\Foo\\Bar', '\\?\\C:\\foo\\bar', '\\/?/foo\\bar', '\\/Server/foo', 'foo//bar/baz'].each do |invalid_path|
      context "path => #{invalid_path}" do
        it 'requires a valid path for file' do
          expect {
            @class.new({ file: invalid_path }) # rubocop:disable RSpec/InstanceVariable
          }.to raise_error(Puppet::ResourceError, %r{file parameter must be a valid absolute path})
        end
      end
    end

    ['/', '/foo', '/foo/../bar', '//foo', '//Server/Foo/Bar', '//?/C:/foo/bar', '/\\Server/Foo', '/foo//bar/baz'].each do |valid_path|
      context "path => #{valid_path}" do
        it 'allows a valid path for file' do
          expect {
            @class.new({ file: valid_path }) # rubocop:disable RSpec/InstanceVariable
          }.not_to raise_error
        end
      end
    end
  end
end
