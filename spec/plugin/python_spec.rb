require 'spec_helper'

RSpec.describe "Python (common/generic functionality)" do
  let(:filename) { 'test.py' }

  specify "basic function call" do
    set_file_contents <<~EOF
      foo = function_call(bar)
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = bar
    EOF
  end

  specify "basic method call" do
    set_file_contents <<~EOF
      foo = object.call(bar)
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = bar
    EOF
  end

  specify "nested method call" do
    set_file_contents <<~EOF
      foo = function1(function2(bar))
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = function1(bar)
    EOF
  end

  specify "arrays" do
    set_file_contents <<~EOF
      foo = array[index]
    EOF

    vim.search 'index'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = index
    EOF
  end

  specify "nested call chain: doesn't jump to the previous call" do
    set_file_contents <<~EOF
      baz = bar(foo( far ).faz( boo ))
    EOF

    vim.search 'faz'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      baz = foo( far ).faz( boo )
    EOF
  end
end
