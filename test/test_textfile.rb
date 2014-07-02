require 'helper'

class TestTextfile < Minitest::Test
  should "sort a simple file" do
    pathname = Pathname.new('textfile.dat')
    file = Tempfile.new(self.class.name)
    file.puts(['3','2','1'])
    file.close
    textfile = Textfile.new(file.path)

    textfile.sort
    
    file = File.open(textfile)
    assert_equal(file.read.split, ['1', '2', '3'])
  end
end
