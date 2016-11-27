*Note: Special thanks to [@faceleg](https://github.com/faceleg), who seems to
have extracted this plugin from my vimfiles before I did. If you'd like a
simpler version of this plugin for whatever reason, feel free to use [this
one](https://github.com/faceleg/delete-surrounding-function-call.vim).*

## Usage

The plugin defines a mapping to delete a surrounding function call (or something similar to one), even if it happens to be namespaced. Some examples:

``` ruby
nested(function_call(cursor_here)) #=> nested(cursor_here)
nested(cursor_here(chewy_center))  #=> cursor_here(chewy_center)
One::Two.new([cursor_here])        #=> [cursor_here]
One::Two.new(Hash[cursor_here])    #=> One::Two.new(cursor_here)
```

``` go
SomeStruct{cursor_here: "Something"} //=> cursor_here: "Something"
```

By pressing `dsf` (which stands for "delete surrounding function call") with the cursor on `cursor_here`, you get the result on the right.

The plugin also defines `csf` to "change surrounding function call", which deletes only the function itself and leaves the cursor waiting to enter a new name.

The plugin also defines text objects for `if` and `af` to manipulate function calls with their contents. Given this example:

``` javascript
var result = function_call(one, two);
```

Typing `daf` ("delete a function call") with the cursor anywhere on `function_call(one, two)` would result in:

``` javascript
var result = ;
```

Typing `dif` ("delete inner function call") with the cursor anywhere on `function_call(one, two)` would result in:

``` javascript
var result = function_call();
```

To learn more about how text objects work, try [`:help text-objects`](http://vimhelp.appspot.com/motion.txt.html#text%2dobjects).

If you'd like to set your own mappings, instead of using the built-ins, simply set the variable `g:dsf_no_mappings` to `1` and use the <Plug> mappings provided by the plugin:


``` vim
let g:dsf_no_mappings = 1

nmap dsf <Plug>DsfDelete
nmap csf <Plug>DsfChange

omap af <Plug>DsfTextObjectA
xmap af <Plug>DsfTextObjectA
omap if <Plug>DsfTextObjectI
xmap if <Plug>DsfTextObjectI
```

Change any of the left-hand sides of the `map` calls to whatever you'd like.

For additional settings, check the full documentation with [`:help dsf-settings`](https://github.com/AndrewRadev/dsf.vim/blob/master/doc/dsf.txt).

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/dsf.vim/blob/master/CONTRIBUTING.md) first for some guidelines.
