require 'spec_helper'

RSpec.describe "Python (delete next)" do
  let(:filename) { 'test.py' }

  specify "basic function call" do
    set_file_contents <<~EOF
      foo = function_call(bar, other_func(baz, bla))
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsnf'
    vim.write

    assert_file_contents <<~EOF
      foo = function_call(bar, baz, bla)
    EOF
  end

  specify "defaulting to standard dsf" do
    set_file_contents <<~EOF
      foo = function_call(bar, other_func(baz, bla))
    EOF

    vim.search 'baz'
    vim.feedkeys 'dsnf'
    vim.write

    assert_file_contents <<~EOF
      foo = function_call(bar, baz, bla)
    EOF
  end

  specify "arrays" do
    set_file_contents <<~EOF
      foo = function_call(array[index])
    EOF

    vim.search 'rray'
    vim.feedkeys 'dsnf'
    vim.write

    assert_file_contents <<~EOF
      foo = function_call(index)
    EOF
  end

  specify "nested call chain: jumps to the next call" do
    set_file_contents <<~EOF
      baz = bar( foo( far ).faz( boo ) )
    EOF

    vim.search 'far'
    vim.feedkeys 'dsnf'
    vim.write

    assert_file_contents <<~EOF
      baz = bar( foo( far ).boo  )
    EOF
  end
end
