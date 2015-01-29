require 'spec_helper'

describe Validation::Rule::TagCount do
  let(:tag_str) { '#i #love #tags' }

  it 'requires a parameter' do
    v = Validation::Validator.new({})
    expect do
      v.rule(:tags, :tag_count)
    end.to raise_error
  end

  it 'validates less tags' do
    v = Validation::Validator.new(OpenStruct.new(tags: tag_str))
    v.rule(:tags, tag_count: { maximum: 5 })

    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it 'validates exactly as many tags' do
    v = Validation::Validator.new(OpenStruct.new(tags: tag_str))
    v.rule(:tags, tag_count: { maximum: 3 })

    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it 'fails for too many tags' do
    v = Validation::Validator.new(OpenStruct.new(tags: tag_str))
    v.rule(:tags, tag_count: { maximum: 1 })

    expect(v).to_not be_valid
    expect(v.errors).to include(:tags)
  end
end
