# encoding: utf-8
require 'helper'

class TestTextfile < Minitest::Test
  def infile(*records)
    file = Tempfile.new(self.class.name)
    file.puts(records)
    file.close
    Textfile.new(file.path)
  end

  should "clear a file" do
    textfile = infile('3','2','1')

    textfile.clear

    file = File.open(textfile.path)
    assert_equal([], file.read.split)
  end

  should "find the intersection of two datasets" do
    tf1 = infile('3','2','1','b')
    tf2 = infile('c','b','a','2')

    tf1.intersection(tf2)

    file = File.open(tf1.path)
    assert_equal(['2','b'], file.read.split)
  end

  should "merge two datasets" do
    tf1 = infile('3','2','1','b')
    tf2 = infile('c','b','a','2')

    tf1.merge(tf2)

    file = File.open(tf1.path)
    assert_equal(['1','2','3','a','b','c'], file.read.split)
  end

  should "sort a simple file" do
    textfile = infile(['3','2','1'])

    textfile.send :sort

    file = File.open(textfile.path)
    assert_equal(file.read.split, ['1', '2', '3'])
  end

  should "sort a file with very long records" do
    textfile = infile('3'*9999,'2','1')

    textfile.send :sort

    file = File.open(textfile.path)
    assert_equal(file.read.split, ['1', '2', '3'*9999])
  end

  should "sort non-ASCII characters" do
    textfile = infile('Muffler','MX Systems','Müller','MySQL')

    textfile.send :sort

    file = File.open(textfile.path, external_encoding: 'UTF-8')
    # OSX collation broken?  Works on Linux.
    assert_equal(file.read.split("\n"), ["Muffler", "Müller", "MX Systems", "MySQL"])
  end
end
