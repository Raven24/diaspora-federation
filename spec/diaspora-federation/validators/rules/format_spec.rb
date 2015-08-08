require 'spec_helper'

describe Validation::Rule::Format do
  context 'rule parameters' do
    it 'fails without parameters' do
      v = Validation::Validator.new({})
      expect do
        v.rule(:name, :format)
      end.to raise_error
    end

    it 'fails with both :with and :without' do
      v = Validation::Validator.new({})
      expect do
        v.rule(:name, format: { with: /./, without: /./ })
      end.to raise_error
    end

    it 'fails when params are not regular expressions' do
      v = Validation::Validator.new({})
      expect do
        v.rule(:name, format: { with: '' })
      end.to raise_error

      expect do
        v.rule(:name, format: { without: '' })
      end.to raise_error
    end
  end

  context 'validation' do
    it 'succeeds matching a regexp' do
      v = Validation::Validator.new(OpenStruct.new(name: 'asdf'))
      v.rule(:name, format: { with: /[a-z]{4}/ })

      expect(v).to be_valid
      expect(v.errors).to be_empty
    end

    it 'succeeds not matching a regexp' do
      v = Validation::Validator.new(OpenStruct.new(name: 'asdf'))
      v.rule(:name, format: { without: /[0-9]{4}/ })

      expect(v).to be_valid
      expect(v.errors).to be_empty
    end

    it 'succeeds allowing empty strings' do
      v = Validation::Validator.new(OpenStruct.new(name: ''))
      v.rule(:name, format: { with: /./, allow_blank: true })

      expect(v).to be_valid
      expect(v.errors).to be_empty
    end

    it 'fails matching a regexp' do
      v = Validation::Validator.new(OpenStruct.new(name: 'asdf'))
      v.rule(:name, format: { with: /[0-9]{4}/ })

      expect(v).to_not be_valid
      expect(v.errors).to include(:name)
    end

    it 'fails not matching a regexp' do
      v = Validation::Validator.new(OpenStruct.new(name: 'asdf'))
      v.rule(:name, format: { without: /[a-z]{4}/ })

      expect(v).to_not be_valid
      expect(v.errors).to include(:name)
    end

    it 'fails denying empty strings' do
      v = Validation::Validator.new(OpenStruct.new(name: ''))
      v.rule(:name, format: { with: /./, allow_blank: false })

      expect(v).to_not be_valid
      expect(v.errors).to include(:name)
    end
  end
end
