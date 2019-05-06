require "test_helper"

#it has a name
#it has and belongs to many products
#we should talk about how we want categories to exisit (like, can you add one, or does it need to be preset)

describe Category do
  let(:category) { categories(:one) }

  it "must be valid" do
    expect(category.valid?).must_equal true
  end

  it "must have a name" do
    category.name = ""

    expect(category.valid?).must_equal false
    expect(category.errors.messages).must_include :name
  end
end
