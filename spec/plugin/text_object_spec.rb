require 'spec_helper'

RSpec.describe "Javascript (text objects)" do
  let(:filename) { 'test.js' }

  it "deletes the function call the cursor is inside of" do
    set_file_contents <<~EOF
      var result = function1(one, two);
      var result = function2(three, four);
    EOF

    vim.search 'one'
    vim.feedkeys 'daf'
    vim.write

    assert_file_contents <<~EOF
      var result = ;
      var result = function2(three, four);
    EOF
  end

  it "deletes the function call the cursor is on" do
    set_file_contents <<~EOF
      var result = function1(one, two);
      var result = function2(three, four);
    EOF

    vim.search 'function2'
    vim.feedkeys 'daf'
    vim.write

    assert_file_contents <<~EOF
      var result = function1(one, two);
      var result = ;
    EOF
  end

  it "doesn't delete anything if not on a function call" do
    set_file_contents <<~EOF
      var result1 = function1(one, two);
      var result2 = function2(three, four);
    EOF

    vim.search 'result2'
    vim.feedkeys 'daf'
    vim.write

    assert_file_contents <<~EOF
      var result1 = function1(one, two);
      var result2 = function2(three, four);
    EOF
  end
end
