require 'spec_helper'

RSpec.describe "LaTeX special handling" do
  let(:filename) { 'test.latex' }

  it "deletes a normal surrounding tag" do
    set_file_contents <<~EOF
      \\usepackage{amsmath}
    EOF

    vim.search 'amsmath'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      amsmath
    EOF
  end

  it "deletes a normal tag" do
    set_file_contents <<~EOF
      -- before
      \\usepackage{amsmath}
      -- after
    EOF

    vim.search 'amsmath'
    vim.feedkeys 'daf'
    vim.write

    assert_file_contents <<~EOF
      -- before

      -- after
    EOF
  end

  it "deletes a surrounding tag with a second pair of brackets" do
    set_file_contents <<~EOF
      y = \\frac{a}{b}x^c + d
    EOF

    vim.search 'a}'
    vim.feedkeys 'dsf'
    vim.write

    assert_file_contents <<~EOF
      y = ax^c + d
    EOF
  end

  it "deletes a tag with a second pair of brackets" do
    set_file_contents <<~EOF
      y = \\frac{a}{b}x^c + d
    EOF

    vim.search 'a}'
    vim.feedkeys 'daf'
    vim.write

    assert_file_contents <<~EOF
      y = x^c + d
    EOF
  end
end
