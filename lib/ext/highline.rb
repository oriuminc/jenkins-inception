# Override output delimiter for defaults from "|blah|" to "<blah>".
class HighLine
  class Question
    private
    def append_default()
      if @question =~ /([\t ]+)\Z/
        @question << "<#{@default}>#{$1}"
      elsif @question == ""
        @question << "<#{@default}>  "
      elsif @question[-1, 1] == "\n"
        @question[-2, 0] =  "  <#{@default}>"
      else
        @question << "  <#{@default}>"
      end
    end
  end
end
