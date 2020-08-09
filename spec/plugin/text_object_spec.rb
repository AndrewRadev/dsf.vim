require 'spec_helper'

RSpec.describe "Javascript (text objects)" do
  let(:filename) { 'test.js' }

  it 'deletes the function call the cursor is on' do
    set_file_contents <<~EOF
      var result = function_call(one, two);
      var result = function_call(three, four);
    EOF

    vim.search 'one'
    vim.feedkeys 'daf'
    vim.write

    assert_file_contents <<~EOF
      var result = ;
      var result = function_call(three, four);
    EOF

    vim.search 'three'
    vim.feedkeys 'daf'
    vim.write

    assert_file_contents <<~EOF
      var result = ;
      var result = ;
    EOF
  end
end
