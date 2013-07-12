require 'spec_helper'

describe Validation::Rule::Guid do
  let(:prefix) { '-----BEGIN RSA PUBLIC KEY-----' }
  let(:suffix) { '-----END RSA PUBLIC KEY-----' }

  let(:key) { "#{prefix}\nAAAAAA==\n#{suffix}\n" }

  it 'will not accept parameters' do
    v = Validation::Validator.new({})
    expect {
      v.rule(:key, rsa_key: { param: true })
    }.to raise_error
  end

  context 'validation' do
    it 'validates an exported RSA key' do
      v = Validation::Validator.new(OpenStruct.new(key: key))
      v.rule(:key, :rsa_key)

      v.should be_valid
      v.errors.should be_empty
    end

    it 'strips whitespace' do
      v = Validation::Validator.new(OpenStruct.new(key: "  \n   #{key}\n \n  "))
      v.rule(:key, :rsa_key)

      v.should be_valid
      v.errors.should be_empty
    end
  end

  it 'fails if the prefix is missing' do
    v = Validation::Validator.new(OpenStruct.new(key: "\nAAAAAA==\n#{suffix}\n"))
    v.rule(:key, :rsa_key)

    v.should_not be_valid
    v.errors.should include(:key)
  end

  it 'fails if the suffix is missing' do
    v = Validation::Validator.new(OpenStruct.new(key: "#{prefix}\nAAAAAA==\n\n"))
    v.rule(:key, :rsa_key)

    v.should_not be_valid
    v.errors.should include(:key)
  end
end
