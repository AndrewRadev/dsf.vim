require 'spec_helper'

RSpec.describe "Ruby" do
  let(:filename) { 'test.rb' }

  specify "namespaced method call" do
    set_file_contents <<~EOF
      foo = One::Two::call(bar)
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = bar
    EOF
  end

  specify "methods ending in special characters" do
    set_file_contents <<~EOF
      foo = one!(two?(three))
    EOF

    vim.search 'three'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = one!(three)
    EOF

    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = three
    EOF
  end

  specify "lambda call shorthand" do
    set_file_contents <<~EOF
      foo = some_lambda.(bar)
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = bar
    EOF
  end
end
