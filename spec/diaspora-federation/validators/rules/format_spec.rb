require 'spec_helper'

describe Validation::Rule::Format do
  context 'rule parameters' do
    it 'fails without parameters' do
      v = Validation::Validator.new({})
      expect {
        v.rule(:name, :format)
      }.to raise_error
    end

    it 'fails with both :with and :without' do
      v = Validation::Validator.new({})
      expect {
        v.rule(:name, format: { with: /./, without: /./ })
      }.to raise_error
    end


    it 'fails when params are not regular expressions' do
      v = Validation::Validator.new({})
      expect {
        v.rule(:name, format: { with: ''})
      }.to raise_error

      expect {
        v.rule(:name, format: { without: ''})
      }.to raise_error
    end
  end

  context 'validation' do
    it 'succeeds matching a regexp' do
      v = Validation::Validator.new(OpenStruct.new(name: 'asdf'))
      v.rule(:name, format: { with: /[a-z]{4}/ })

      v.should be_valid
      v.errors.should be_empty
    end

    it 'succeeds not matching a regexp' do
      v = Validation::Validator.new(OpenStruct.new(name: 'asdf'))
      v.rule(:name, format: { without: /[0-9]{4}/ })

      v.should be_valid
      v.errors.should be_empty
    end

    it 'succeeds allowing empty strings' do
      v = Validation::Validator.new(OpenStruct.new(name: ''))
      v.rule(:name, format: { with: /./, allow_blank: true })

      v.should be_valid
      v.errors.should be_empty
    end

    it 'fails matching a regexp' do
      v = Validation::Validator.new(OpenStruct.new(name: 'asdf'))
      v.rule(:name, format: { with: /[0-9]{4}/ })

      v.should_not be_valid
      v.errors.should include(:name)
    end

    it 'fails not matching a regexp' do
      v = Validation::Validator.new(OpenStruct.new(name: 'asdf'))
      v.rule(:name, format: { without: /[a-z]{4}/ })

      v.should_not be_valid
      v.errors.should include(:name)
    end

    it 'fails denying empty strings' do
      v = Validation::Validator.new(OpenStruct.new(name: ''))
      v.rule(:name, format: { with: /./, allow_blank: false })

      v.should_not be_valid
      v.errors.should include(:name)
    end
  end
end
