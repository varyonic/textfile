require 'helper'

class TestTextfile < Minitest::Test
  def infile(data)
    file = Tempfile.new(self.class.name)
    file.puts(data)
    file.close
    file
  end

  should "sort a simple file" do
    file = infile(['3','2','1'])

    textfile = Textfile.new(file.path)
    textfile.sort

    file = File.open(textfile)
    assert_equal(file.read.split, ['1', '2', '3'])
  end

  should "sort a file with very long records" do
    file = infile(['3'*9999,'2','1'])

    textfile = Textfile.new(file.path)
    textfile.sort

    file = File.open(textfile)
    assert_equal(file.read.split, ['1', '2', '3'*9999])
  end
end
