#The MIT LICENSE

#Copyright (c) 2010 Gabriel Horner

#Permission is hereby granted, free of charge, to any person obtaining
#a copy of this software and associated documentation files (the
#"Software"), to deal in the Software without restriction, including
#without limitation the rights to use, copy, modify, merge, publish,
#distribute, sublicense, and/or sell copies of the Software, and to
#permit persons to whom the Software is furnished to do so, subject to
#the following conditions:

#The above copyright notice and this permission notice shall be
#included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#Forked from https://github.com/cldwalker/menu

module Menu
  extend self

  def ask
    $stdin.reopen '/dev/tty'
    $stdin.gets.chomp
  end

  def unic_run(array)
    unic_prompt(array)
    answer = ask
    return unic_answer(array, answer)
  end

  def unic_answer(array, input)
    if input[/(\d+)/]
      index = $1.to_i - 1
      return array[index] if array[index]
    else
      abort("`#{input}' is an invalid choice.")
    end
  end

  def unic_prompt(lines)
    ljust_size = lines.size.to_s.size + 1
    lines.each_with_index {|obj,i|
      puts "#{i+1}.".ljust(ljust_size) + " " +obj
    }
    print "\nSpecify your choice\nChoose: "
  end
end
