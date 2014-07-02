require 'helper'

class TestTextfile < Minitest::Test
  should "sort a simple file" do
    file = Tempfile.new(self.class.name)
    file.puts(['3','2','1'])
    file.close

    textfile = Textfile.new(file.path)
    textfile.sort

    file = File.open(textfile)
    assert_equal(file.read.split, ['1', '2', '3'])
  end

  should "sort a file with very long records" do
    file = Tempfile.new(self.class.name)
    file.puts(['3'*9999,'2','1'])
    file.close

    textfile = Textfile.new(file.path, debug: true, bufsiz: 2*4096)
    textfile.sort

    file = File.open(textfile)
    assert_equal(file.read.split, ['1', '2', '3'*9999])
  end
end
