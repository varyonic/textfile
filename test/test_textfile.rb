# encoding: utf-8
require 'helper'

class TestTextfile < Minitest::Test
  def infile(data)
    file = Tempfile.new(self.class.name)
    file.puts(data)
    file.close
    file
  end

  should "clear a file" do
    file = infile(['3','2','1'])

    textfile = Textfile.new(file.path)
    textfile.clear

    file = File.open(textfile)
    assert_equal([], file.read.split)
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

  should "sort non-ASCII characters" do
    file = infile(['Muffler','MX Systems','Müller','MySQL'])

    textfile = Textfile.new(file.path)
    textfile.sort

    file = File.open(textfile, external_encoding: 'UTF-8')
    assert_equal(file.read.split("\n"), ["MX Systems", "Muffler", "MySQL", "Müller"])
  end
end
