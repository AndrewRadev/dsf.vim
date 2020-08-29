require 'spec_helper'

RSpec.describe "Ruby (Multiline)" do
  let(:filename) { 'test.rb' }

  specify "basic" do
    set_file_contents <<~EOF
      foo = function_call(
        "bar"
      ).quux
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = "bar".quux
    EOF
  end

  specify "with multiple elements" do
    set_file_contents <<~EOF
      foo = function_call(
        "one",
        "two",
        "three"
      )
    EOF

    vim.search 'two'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = "one",
        "two",
        "three"
    EOF
  end

  specify "with a following line" do
    set_file_contents <<~EOF
      foo = function_call(
        "one"
      )

      two
    EOF

    vim.search 'one'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo = "one"

      two
    EOF
  end

  specify "delete-next" do
    set_file_contents <<~EOF
      baz = bar(
        foo( far ).
        faz( boo )
      ) #
    EOF

    vim.search 'bar'
    vim.feedkeys 'dsnf'
    vim.write

    assert_file_contents <<~EOF
      baz = foo( far ).
        faz( boo ) #
    EOF

    vim.search 'far'
    vim.feedkeys 'dsnf'
    vim.write

    # Note: whitespace before closing bracket cleared
    assert_file_contents <<~EOF
      baz = foo( far ).
        boo #
    EOF
  end

  specify "tries to preserve indentation" do
    set_file_contents <<~EOF
      foo(
        bar(
          one,
          two
        )
      )
    EOF

    vim.search 'one'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      foo(
        one,
        two
      )
    EOF
  end
end
