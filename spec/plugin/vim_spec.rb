require 'spec_helper'

RSpec.describe "Vim" do
  let(:filename) { 'test.vim' }

  specify "autoloaded function" do
    set_file_contents <<~EOF
      let foo = one#two#three(bar)
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      let foo = bar
    EOF
  end

  specify "script-local function" do
    set_file_contents <<~EOF
      let foo = s:FunctionCall(bar)
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      let foo = bar
    EOF
  end
end
